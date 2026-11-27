import 'dart:async';

import 'package:flutter_map/flutter_map.dart';
import 'package:osm_api/osm_api.dart' as osmapi;

import '/api/osm_element_query_api.dart';
import '/api/osm_element_upload_api.dart';
import '/api/uploaded_elements_overlay.dart';
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
import '/models/tag_diff.dart';
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
      (element) => _deriveUpdate(
        element,
        action: ElementUpdateAction.update,
      ),
    );
    return controller.addStream(elementUpdates);
  });

  final _elementPool = OSMElementProcessor();

  final _osmElementQueryHandler = CachedOSMElementQueryAPI();

  final _uploadedElements = UploadedElementsOverlay(timeToLive: kElementCacheTimeToLive);

  /// Called whenever the elements of a stop area were loaded (from the cache or the server)
  /// and before they are published via the [elementStream].
  ///
  /// The elements are the ones contained in the element pool.

  Future<void> onElementsLoaded(Iterable<ProcessedElement> elements) async {}

  /// Whether the given element has a finished questionnaire that is not uploaded yet.
  /// Used to mark these elements on the map.

  bool hasFinishedQuestionnaire(ElementIdentifier element) => false;

  ElementUpdate _deriveUpdate(ProcessedElement element, {required ElementUpdateAction action}) {
    return ElementUpdate.derive(
      element,
      action: action,
      hasFinishedQuestionnaire: hasFinishedQuestionnaire(element),
    );
  }

  /// Sends an update for the given element, for example after its questionnaire state changed.

  Future<void> refreshElement(ProcessedElement element) async {
    final qCatalog = await questionCatalog;
    // only update elements that are already visible
    if (!QuestionFilter(qCatalog).matches(element)) return;
    if (!loadedStopAreas.any((stopArea) => AreaOverlapFilter(stopArea).matches(element))) return;
    _elementStreamController.add(_deriveUpdate(element, action: ElementUpdateAction.update));
  }

  @override
  Future<void> updateQuestionCatalog(QuestionCatalogChange questionCatalogChange) async {
    super.updateQuestionCatalog(questionCatalogChange);
    final existingElements = _filterElements(
      _buildFiltersForStopAreas(loadedStopAreas),
      Stream.fromIterable(_elementPool.elements),
    );
    _elementStreamController.add(const ElementUpdate(action: ElementUpdateAction.clear));
    return existingElements
        .map((element) => _deriveUpdate(element, action: ElementUpdateAction.update))
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
        (element) => _deriveUpdate(
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
        // query elements by stop areas bbox (from cache if available)
        var elementBundle = await _osmElementQueryHandler.queryByStopArea(stopArea);
        // replace outdated cached elements by their uploaded version
        elementBundle = await _uploadedElements.apply(elementBundle);
        // process stop area elements
        final stopAreaElements = _elementPool
            .add(elementBundle)
            .map((record) => record.element)
            .toList();
        await onElementsLoaded(stopAreaElements);
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
  /// The changes are applied to the current server version of the element (see [ProxyElement.rebaseOnto]).
  /// [beforePublish] is called once after the changes were found to be applicable
  /// and before they are written to the server.
  ///
  /// Throws an [ElementConflictException] if the element was changed in a contradicting way or deleted.
  /// In this case the element is updated to the server state.
  /// Throws any other error if the upload fails.

  Future<void> uploadElement(
    ProxyElement element,
    AuthenticatedUser<int> user, {
    Future<void> Function()? beforePublish,
  }) async {
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
      // check for conflicts before anything is uploaded
      var rebased = await _rebase(element, uploadAPI);
      await beforePublish?.call();

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

      osmapi.OSMElement uploaded;
      try {
        uploaded = await element.publish(uploadAPI, changesetId, rebased);
      } on osmapi.OSMConflictException {
        // the element was changed between querying and uploading it, so retry once
        rebased = await _rebase(element, uploadAPI);
        uploaded = await element.publish(uploadAPI, changesetId, rebased);
      }
      await _uploadedElements.record(uploaded);
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
            (record) => _deriveUpdate(
              record.element,
              action: record.matches ? ElementUpdateAction.update : ElementUpdateAction.remove,
            ),
          )
          .forEach(_elementStreamController.add);
    } finally {
      uploadAPI.dispose();
    }
  }

  /// Queries the current server version of the element and applies the changes to it.
  ///
  /// On conflict the element is updated to the server state (or removed if it was deleted)
  /// and an [ElementConflictException] is thrown.

  Future<osmapi.OSMElement> _rebase(ProxyElement element, OSMElementUploadAPI uploadAPI) async {
    final osmapi.OSMElement current;
    try {
      current = await uploadAPI.getElement(element.type, element.id);
    } on osmapi.OSMNotFoundException {
      _onConflict(element, null);
      throw const ElementConflictException('Element was deleted in the meantime.');
    } on osmapi.OSMGoneException {
      _onConflict(element, null);
      throw const ElementConflictException('Element was deleted in the meantime.');
    }
    try {
      return element.rebaseOnto(current);
    } on ElementConflictException {
      _onConflict(element, current);
      rethrow;
    }
  }

  void _onConflict(ProxyElement element, osmapi.OSMElement? current) {
    if (current == null) {
      _elementStreamController.add(
        _deriveUpdate(element.original, action: ElementUpdateAction.remove),
      );
      return;
    }
    element.adopt(current);
    unawaited(_uploadedElements.record(current));
    unawaited(
      questionCatalog.then((qCatalog) {
        _elementStreamController.add(
          _deriveUpdate(
            element.original,
            action: QuestionFilter(qCatalog).matches(element.original)
                ? ElementUpdateAction.update
                : ElementUpdateAction.remove,
          ),
        );
      }),
    );
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

  ElementUpdate.derive(
    ProcessedElement element, {
    required this.action,
    bool hasFinishedQuestionnaire = false,
  }) : element = MapFeatures()
           .representElement(element)
           .copyWith(hasFinishedQuestionnaire: hasFinishedQuestionnaire);
}
