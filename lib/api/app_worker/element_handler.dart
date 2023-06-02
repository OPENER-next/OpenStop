import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:osm_api/osm_api.dart' as osmapi;

import '/models/element_variants/element_identifier.dart';
import '/models/map_feature_collection.dart';
import '/api/osm_element_query_api.dart';
import '/models/element_processing/element_filter.dart';
import '/models/element_processing/element_processor.dart';
import '/models/element_variants/base_element.dart';
import '/models/geographic_geometries.dart';
import '/models/stop_area_processing/stop_area.dart';
import '/utils/service_worker.dart';
import 'map_feature_handler.dart';
import 'question_catalog_handler.dart';
import 'stop_area_handler.dart';

/// Allows querying stop area elements.
///
/// All downloaded elements are cached in the [OSMElementProcessor].

mixin ElementHandler<M> on ServiceWorker<M>, StopAreaHandler<M>, MapFeatureHandler<M>, QuestionCatalogHandler<M> {
  final _elementStreamController = StreamController<ElementUpdate>();

  /// Note for overlapping stop areas this may return the same element twice
  ///
  /// While the underlying code knows if an element was already downloaded,
  /// it doesn't know whether it already passed a stop area filter (was visible to the user).
  ///
  /// Moving the filters inside the element processing step and removing
  /// non matching elements there is not a good idea, due to child/parent reference problems.

  Stream<ElementUpdate> get elementStream => _elementStreamController.stream;

  final _elementPool = OSMElementProcessor();

  final _osmElementQueryHandler = OSMElementQueryAPI();

  /// All stop areas from [stopAreaCache] where elements have been loaded.

  final _loadedStopAreas = <StopArea>{};

  final _loadingStopAreas = <StopArea>{};

  /// Retrieves all stop areas in the given bounds and queries the elements for any unloaded stop area.
  ///
  /// New elements will be added to the [elementStream].

  Future<void> queryElements(LatLngBounds bounds) async {
    final closeStopAreas = getStopAreasByBounds(bounds);
    final mfCollection = await mapFeatureCollection;
    final futures = <Future<void>>[];

    for (final stopArea in closeStopAreas) {
      final elements = _queryElementsByStopArea(stopArea);
      // filter elements
      final filteredElements = _filterElements(
        _buildFiltersForStopArea(stopArea), elements,
      );
      // construct element updates
      final elementUpdates = filteredElements.map((element) => ElementUpdate.derive(
        element, mfCollection, ElementChange.create,
      ));
      // add newly queried elements to stream
      futures.add(
        elementUpdates.forEach(_elementStreamController.add),
      );
    }
    // used to only complete this function once all queries and processing is completed
    // and also to forward any errors (especially query errors)
    await Future.wait(futures, eagerError: true);
  }

  Stream<ProcessedElement> _queryElementsByStopArea(StopArea stopArea) async* {
    if (!_loadingStopAreas.contains(stopArea) && !_loadedStopAreas.contains(stopArea)) {
      // add to current loading stop areas and mark as loading
      _loadingStopAreas.add(stopArea);
      markStopArea(stopArea, StopAreaState.loading);

      try {
        // query elements by stop areas bbox
        final elementBundle = await _osmElementQueryHandler.queryByBBox(stopArea.bounds);
        // process stop area elements
        final stopAreaElements = _elementPool
          .add(elementBundle)
          .map((record) => record.element);
        // on success add to loaded stop areas and mark accordingly
        _loadedStopAreas.add(stopArea);

        if (await stopAreaHasQuestions(stopArea, stopAreaElements)) {
          markStopArea(stopArea, StopAreaState.incomplete);
        }
        else {
          markStopArea(stopArea, StopAreaState.complete);
        }
        // return new elements
        yield* Stream.fromIterable(stopAreaElements);
      }
      catch(e) {
        markStopArea(stopArea, StopAreaState.unloaded);
        rethrow;
      }
      finally {
        _loadingStopAreas.remove(stopArea);
      }
    }
  }

  /// Quickly find a downloaded element by its identifier.

  ProcessedElement<osmapi.OSMElement, GeographicGeometry>? findElement(ElementIdentifier elementIdentifier) {
    return _elementPool.find(elementIdentifier.type, elementIdentifier.id);
  }

  /// Send update events for a given element and its dependents.

  Future<void> updateElementAndDependents(ProcessedElement element) async {
    final mfCollection = await mapFeatureCollection;
    final qCatalog = await questionCatalog;

    final ElementChange change;
    if (QuestionFilter(questionCatalog: qCatalog).matches(element)) {
      change = ElementChange.update;
    }
    else {
      change = ElementChange.remove;
    }


// TODO trigger reverse update element and dependent elements since new elements might match after an element got updated

    [element]
      .map((element) => ElementUpdate.derive(element, mfCollection, change))
      .forEach(_elementStreamController.add);
  }

  /// Finds a stop area a given element lies within.

  StopArea findCorrespondingStopArea(ProcessedElement element) {
    return _loadedStopAreas.firstWhere(
      (stopArea) => stopArea.isPointInside(element.geometry.center),
      orElse: () => throw StateError('No surrounding stop area found for ${element.type} ${element.id}.'),
    );
  }

  Future<bool> stopAreaHasQuestions(StopArea stopArea, [Iterable<ProcessedElement>? elements]) async {
    final filteredElements = _filterElements(
      _buildFiltersForStopArea(stopArea),
      Stream.fromIterable(elements ?? _elementPool.elements),
    );
    return !(await filteredElements.isEmpty);
  }

  Stream<ProcessedElement> _filterElements(Stream<ElementFilter> filters, Stream<ProcessedElement> elements) async* {
    yield* await filters.fold<Stream<ProcessedElement>>(
      elements,
      (elements, filter) => filter.asyncFilter(elements),
    );
  }

  Stream<ElementFilter> _buildFiltersForStopArea(StopArea stopArea) async* {
    yield QuestionFilter(questionCatalog: await questionCatalog);
    yield AreaFilter(area: stopArea);
  }

  @override
  exit() {
    _osmElementQueryHandler.dispose();
    super.exit();
  }
}


class ElementRepresentation extends ElementIdentifier {
  @override
  final int id;

  @override
  final osmapi.OSMElementType type;

  final GeographicGeometry geometry;
  final String name;
  final IconData icon;

  const ElementRepresentation({
    required this.id,
    required this.type,
    required this.name,
    required this.icon,
    required this.geometry,
  });

  factory ElementRepresentation.derive(ProcessedElement element, MapFeatureCollection mapFeatureCollection) {
    final mapFeature = mapFeatureCollection.getMatchingFeature(element);
    return ElementRepresentation(
      id: element.id,
      type: element.type,
      geometry: element.geometry,
      icon: mapFeature?.icon ?? MdiIcons.help,
      name: mapFeature?.labelByElement(element) ?? mapFeature?.name ?? '',
    );
  }
}

enum ElementChange {
  create, update, remove
}

class ElementUpdate {
  final ElementRepresentation element;
  final ElementChange change;

  const ElementUpdate({
    required this.element,
    required this.change,
  });

  ElementUpdate.derive(ProcessedElement element, MapFeatureCollection mapFeatureCollection, this.change) :
    element = ElementRepresentation.derive(
      element, mapFeatureCollection,
    );
}
