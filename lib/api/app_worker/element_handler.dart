import 'dart:async';

import 'package:flutter_map/flutter_map.dart';
import 'package:osm_api/osm_api.dart' as osmapi;

import '/api/osm_element_query_api.dart';
import '/api/osm_element_upload_api.dart';
import '/models/affected_elements_detector.dart';
import '/models/authenticated_user.dart';
import '/models/changeset_info_generator.dart';
import '/models/element_processing/element_filter.dart';
import '/models/element_processing/element_processor.dart';
import '/models/element_variants/base_element.dart';
import '/models/element_variants/element_identifier.dart';
import '/models/geographic_geometries.dart';
import '/models/map_features/map_feature_representation.dart';
import '/models/map_features/map_features.dart';
import '/models/question_catalog/question_catalog_reader.dart';
import '/models/stop_area/stop_area.dart';
import '/utils/service_worker.dart';
import '/utils/stream_utils.dart';
import 'locale_handler.dart';
import 'question_catalog_handler.dart';
import 'stop_area_handler.dart';

/// Allows querying stop area elements.
///
/// All downloaded elements are cached in the [OSMElementProcessor].

mixin ElementHandler<M>
    on ServiceWorker<M>, StopAreaHandler<M>, QuestionCatalogHandler<M>, LocaleHandler<M> {
  final _elementStreamController = StreamController<ElementUpdate>();

  /// A MultiStream that returns any existing elements on initial subscription.
  ///
  /// Note for overlapping stop areas this may return the same element twice
  ///
  /// While the underlying code knows if an element was already downloaded,
  /// it doesn't know whether it already passed a stop area filter (was visible to the user).
  ///
  /// Moving the filters inside the element processing step and removing
  /// non matching elements there is not a good idea, due to child/parent reference problems.

  late final elementStream = _elementStreamController.stream.makeMultiStreamAsync((
    controller,
  ) async {
    final existingElements = _filterElements(
      _buildFiltersForStopAreas(loadedStopAreas),
      Stream.fromIterable(_elementPool.elements),
    );
    final elementUpdates = existingElements.map(
      (element) => ElementUpdate.derive(
        element,
        action: ElementUpdateAction.update,
      ),
    );
    return controller.addStream(elementUpdates);
  });

  final _elementPool = OSMElementProcessor();

  final _osmElementQueryHandler = OSMElementQueryAPI();

  @override
  Future<void> updateQuestionCatalog(QuestionCatalogChange questionCatalogChange) async {
    super.updateQuestionCatalog(questionCatalogChange);
    final existingElements = _filterElements(
      _buildFiltersForStopAreas(loadedStopAreas),
      Stream.fromIterable(_elementPool.elements),
    );
    _elementStreamController.add(const ElementUpdate(action: ElementUpdateAction.clear));
    return existingElements
        .map((element) => ElementUpdate.derive(element, action: ElementUpdateAction.update))
        .forEach(_elementStreamController.add);
  }

  /// Retrieves all stop areas in the given bounds and queries the elements for any unloaded stop area.
  ///
  /// All stop area elements will be added to the [elementStream].

  Future<void> queryElements(LatLngBounds bounds) {
    final closeStopAreas = getStopAreasByBounds(bounds);
    final futures = <Future<void>>[];

    for (final stopArea in closeStopAreas) {
      final elements = _queryElementsByStopArea(stopArea);
      // filter elements
      final filteredElements = _filterElements(
        _buildFiltersForStopArea(stopArea),
        elements,
      );
      // construct element updates
      final elementUpdates = filteredElements.map(
        (element) => ElementUpdate.derive(
          element,
          action: ElementUpdateAction.update,
        ),
      );
      // add newly queried elements to stream
      futures.add(
        elementUpdates.forEach(_elementStreamController.add),
      );
    }
    // used to only complete this function once all queries and processing is completed
    // and also to forward any errors (especially query errors)
    return Future.wait(futures, eagerError: true);
  }

  /// Returns all queried elements even elements that have already been queried
  /// by other stop areas (even though we could easily filter them).
  ///
  /// This is important because we don't know whether an element has already passed
  /// an area filter (in other words has already been added to the map) or not.
  ///
  /// For example an element could be queried because it is part of a relation
  /// while not being inside the stop area which caused the query.
  /// If this element is later re-queried from a different stop area in which it lies within,
  /// then excluding it would be wrong because it hasn't yet been added to the map.

  Stream<ProcessedElement> _queryElementsByStopArea(StopArea stopArea) async* {
    if (stopAreaIsUnloaded(stopArea)) {
      // add to current loading stop areas and mark as loading
      markStopArea(stopArea, StopAreaState.loading);
      try {
        // query elements by stop areas bbox
        final elementBundle = await _osmElementQueryHandler.queryByBBox(stopArea);
        // process stop area elements
        final stopAreaElements = _elementPool.add(elementBundle).map((record) => record.element);
        // on success add to loaded stop areas and mark accordingly
        if (await stopAreaHasQuestions(stopArea, stopAreaElements)) {
          markStopArea(stopArea, StopAreaState.incomplete);
        } else {
          markStopArea(stopArea, StopAreaState.complete);
        }
        yield* Stream.fromIterable(stopAreaElements);
      } catch (e) {
        markStopArea(stopArea, StopAreaState.unloaded);
        rethrow;
      }
    }
  }

  /// Quickly find a downloaded element by its identifier.

  ProcessedElement<osmapi.OSMElement, GeographicGeometry>? findElement(
    ElementIdentifier elementIdentifier,
  ) {
    return _elementPool.find(elementIdentifier.type, elementIdentifier.id);
  }

  /// Uploads a given element.
  /// Sends update events for the given element and its dependents.
  ///
  /// Throws if the upload fails.

  Future<void> uploadElement(ProxyElement element, AuthenticatedUser user) async {
    final qCatalog = await questionCatalog;

    final stopArea = findCorrespondingStopArea(element);

    // upload with first StopArea occurrence
    final uploadAPI = OSMElementUploadAPI(
      authenticatedUser: user,
    );

    try {
      // upload element and detect elements that are affected by this change
      final diffDetector = AffectedElementsDetector(questionCatalog: qCatalog);
      diffDetector.takeSnapshot(element.original);
      final changesetId = await uploadAPI.createOrReuseChangeset(stopArea, element, (
        stopArea,
        elements,
      ) {
        return ChangesetInfo(
          comment: ChangesetCommentGenerator.fromContext(
            stopArea: stopArea,
            modifiedElements: elements,
            userLocales: userLocales,
          ).toString(),
          locale: appLocale.toLanguageTag(),
        );
      });
      await element.publish(uploadAPI, changesetId);
      final affectedElements = diffDetector.takeSnapshot(element.original);

      // update stop area state
      if (await stopAreaHasQuestions(stopArea, _elementPool.elements)) {
        markStopArea(stopArea, StopAreaState.incomplete);
      } else {
        markStopArea(stopArea, StopAreaState.complete);
      }

      affectedElements
          // add the element itself to the affected elements
          .followedBy([
            AffectedElementsRecord(
              element: element.original,
              matches: QuestionFilter(qCatalog).matches(element),
            ),
          ])
          // send update messages to the main thread
          .map(
            (record) => ElementUpdate.derive(
              record.element,
              action: record.matches ? ElementUpdateAction.update : ElementUpdateAction.remove,
            ),
          )
          .forEach(_elementStreamController.add);
    } finally {
      uploadAPI.dispose();
    }
  }

  @override
  Future<bool> stopAreaHasQuestions(
    StopArea stopArea, [
    Iterable<ProcessedElement>? elements,
  ]) async {
    final filteredElements = _filterElements(
      _buildFiltersForStopArea(stopArea),
      Stream.fromIterable(elements ?? _elementPool.elements),
    );
    return !(await filteredElements.isEmpty);
  }

  Stream<ProcessedElement> _filterElements(
    Stream<ElementFilter> filters,
    Stream<ProcessedElement> elements,
  ) async* {
    yield* await filters.fold<Stream<ProcessedElement>>(
      elements,
      (elements, filter) => filter.asyncFilter(elements),
    );
  }

  Stream<ElementFilter> _buildFiltersForStopArea(StopArea stopArea) async* {
    yield QuestionFilter(await questionCatalog);
    yield AreaOverlapFilter(stopArea);
  }

  Stream<ElementFilter> _buildFiltersForStopAreas(Iterable<StopArea> stopAreas) async* {
    yield QuestionFilter(await questionCatalog);
    yield AnyFilter(stopAreas.map(AreaOverlapFilter.new));
  }

  @override
  void exit() {
    _osmElementQueryHandler.dispose();
    _elementStreamController.close();
    super.exit();
  }
}

enum ElementUpdateAction { update, remove, clear }

class ElementUpdate {
  final MapFeatureRepresentation? element;
  final ElementUpdateAction action;

  const ElementUpdate({
    required this.action,
    this.element,
  });

  ElementUpdate.derive(ProcessedElement element, {required this.action})
    : element = MapFeatures().representElement(element);
}
