import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart' hide UnmodifiableSetView;
import 'package:flutter/widgets.dart' hide ProxyElement;

import '/models/element_processing/element_pool.dart';
import '/models/authenticated_user.dart';
import '/models/element_processing/element_filter.dart';
import '/models/element_variants/base_element.dart';
import '/models/map_feature_collection.dart';
import '/models/question_catalog/question_catalog.dart';
import '/models/stop_area.dart';

class OSMElementProvider extends ChangeNotifier {

  final _loadingStopAreas = <StopArea>{};

  final _stopAreaToElementsMapping = <StopArea, Set<ProcessedElement>>{};

  MapFeatureCollection _mapFeatureCollection;

  final Future<ElementPool> _elementPool;

  OSMElementProvider({
    required QuestionCatalog questionCatalog,
    required MapFeatureCollection mapFeatureCollection
  }) :
    _mapFeatureCollection = mapFeatureCollection,
    _elementPool = _init(questionCatalog);


  static Future<ElementPool> _init(QuestionCatalog questionCatalog) async {
    final elementPool = await ElementPool.spawn();
    await elementPool.applyFilters([
      QuestionFilter(questionCatalog: questionCatalog)
    ]);
    return elementPool;
  }


  /// Used to update all dependency injections.
  /// Updating the question catalog will re-extract/filter all osm elements.

  void update({
    required QuestionCatalog questionCatalog,
    required MapFeatureCollection mapFeatureCollection
  }) async {
    final entries = await (await _elementPool).applyFilters([
      QuestionFilter(questionCatalog: questionCatalog)
    ]);
    _stopAreaToElementsMapping.addEntries(entries);

    _mapFeatureCollection = mapFeatureCollection;
  }


  UnmodifiableSetView<StopArea> get loadingStopAreas
    => UnmodifiableSetView(_loadingStopAreas);


  Set<ProcessedElement>? elementsOf(StopArea stopArea) {
    return _stopAreaToElementsMapping[stopArea];
  }

  /// Get a set of all loaded and filtered osm elements
  /// Since this returns a Set this won't contain any duplicates.

  UnionSet<ProcessedElement> get extractedOsmElements {
    // this set won't contain duplicated osm elements
    // since a processed element has a custom equality function based on the underlying osm element
    return UnionSet.from(_stopAreaToElementsMapping.values.map(
      (list) => list)
    );
  }

  /// Check whether a stop area has been loaded and extracted.

  bool stopAreaIsLoaded(StopArea stopArea) => _stopAreaToElementsMapping.containsKey(stopArea);


  /// Check whether a stop area is currently loading.

  bool stopAreaIsLoading(StopArea stopArea) => _loadingStopAreas.contains(stopArea);

  /// Load and extract elements from a given stop area and question catalog.

  Future<void> loadElementsFromStopArea(StopArea stopArea) async {
    if (!stopAreaIsLoading(stopArea) && !stopAreaIsLoaded(stopArea)) {
      // add to loading stop areas
      _loadingStopAreas.add(stopArea);
      notifyListeners();

      try {
        // query elements
        final entry = await (await _elementPool).query(stopArea);
        _stopAreaToElementsMapping[entry.key] = entry.value;
      }
      finally {
        _loadingStopAreas.remove(stopArea);
        notifyListeners();
      }
    }
  }


  /// Upload the changes made by this questionnaire with the given authenticated user.

  Future<void> upload({
    required ProxyElement proxyElement,
    required AuthenticatedUser authenticatedUser,
    required Locale locale
  }) async {
    try {
      // update all affected stop areas afterwards
      final entries = await (await _elementPool).update(ElementUpdateData(
        element: proxyElement,
        mapFeatureCollection: _mapFeatureCollection,
        authenticatedUser: authenticatedUser,
        languageCode: locale.languageCode,
      ));

      _stopAreaToElementsMapping.addEntries(entries);
    }
    finally {
      notifyListeners();
    }
  }


  @override
  void dispose() {
    _elementPool.then((value) => value.dispose());
    super.dispose();
  }
}
