import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart' hide ProxyElement;

import '/models/element_processing/element_worker.dart';
import '/models/authenticated_user.dart';
import '/models/element_processing/element_filter.dart';
import '/models/element_variants/base_element.dart';
import '/models/map_feature_collection.dart';
import '/models/question_catalog/question_catalog.dart';
import '/models/stop_area.dart';

class OSMElementProvider extends ChangeNotifier {

  final _loadingStopAreas = <StopArea>{};

  Set<ProcessedElement> _elements = {};

  MapFeatureCollection _mapFeatureCollection;

  final Future<ElementWorker> _elementPool;

  OSMElementProvider({
    required QuestionCatalog questionCatalog,
    required MapFeatureCollection mapFeatureCollection
  }) :
    _mapFeatureCollection = mapFeatureCollection,
    _elementPool = _init(questionCatalog);


  static Future<ElementWorker> _init(QuestionCatalog questionCatalog) async {
    final elementPool = await ElementWorker.spawn();
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
    _elements = await (await _elementPool).applyFilters([
      QuestionFilter(questionCatalog: questionCatalog)
    ]);
    _mapFeatureCollection = mapFeatureCollection;
  }


  UnmodifiableSetView<StopArea> get loadingStopAreas =>
    UnmodifiableSetView(_loadingStopAreas);


  /// Get a set of all loaded and filtered osm elements

  UnmodifiableSetView<ProcessedElement> get extractedOsmElements =>
    UnmodifiableSetView(_elements);


  /// Check whether a stop area is currently loading.

  bool stopAreaIsLoading(StopArea stopArea) => _loadingStopAreas.contains(stopArea);

  /// Load and extract elements from a given stop area and question catalog.

  Future<void> loadElementsFromStopArea(StopArea stopArea) async {
    if (!stopAreaIsLoading(stopArea)) {
      // add to loading stop areas
      _loadingStopAreas.add(stopArea);
      notifyListeners();

      try {
        // query elements
        _elements = await (await _elementPool).query(stopArea);
      }
      finally {
        _loadingStopAreas.remove(stopArea);
        notifyListeners();
      }
    }
  }


  /// Check whether the given stop area has any matching elements left.
  ///
  /// The stop area must be loaded in advance.

  Future<bool> stopAreaHasElements(StopArea stopArea) async {
    return (await _elementPool).hasElements(stopArea);
  }


  /// Upload the changes made by this questionnaire with the given authenticated user.

  Future<void> upload({
    required ProxyElement proxyElement,
    required AuthenticatedUser authenticatedUser,
    required Locale locale
  }) async {
    try {
      // update elements afterwards
      _elements = await (await _elementPool).update(ElementUpdateData(
        element: proxyElement,
        mapFeatureCollection: _mapFeatureCollection,
        authenticatedUser: authenticatedUser,
        languageCode: locale.languageCode,
      ));
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
