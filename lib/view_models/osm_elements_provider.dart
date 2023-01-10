import 'dart:collection';

import 'package:collection/collection.dart' hide UnmodifiableSetView;
import 'package:flutter/widgets.dart' hide ProxyElement;

import '/models/element_processing/element_filter.dart';
import '/models/element_processing/element_pool.dart';
import '/api/osm_element_upload_api.dart';
import '/models/authenticated_user.dart';
import '/models/map_feature_collection.dart';
import '/models/element_variants/base_element.dart';
import '/models/question_catalog/question_catalog.dart';
import '/api/osm_element_query_api.dart';
import '/models/stop_area.dart';

class OSMElementProvider extends ChangeNotifier {

  final _osmElementQueryHandler = OSMElementQueryAPI();

  final _loadingStopAreas = <StopArea>{};

  final _stopAreaToElementsMapping = <StopArea, ElementPool>{};

  QuestionCatalog _questionCatalog;

  MapFeatureCollection _mapFeatureCollection;

  OSMElementProvider({
    required QuestionCatalog questionCatalog,
    required MapFeatureCollection mapFeatureCollection
  }) :
    _questionCatalog = questionCatalog,
    _mapFeatureCollection = mapFeatureCollection;

  /// Used to update all dependency injections.
  /// Updating the question catalog will re-extract/filter all osm elements.

  void update({
    required QuestionCatalog questionCatalog,
    required MapFeatureCollection mapFeatureCollection
  }) async {
    if (questionCatalog != _questionCatalog) {
      _questionCatalog = questionCatalog;
      await Future.wait([
        for (final entry in _stopAreaToElementsMapping.entries)
          entry.value.filter(_buildFilters(entry.key))
      ]);
    }

    _mapFeatureCollection = mapFeatureCollection;
    notifyListeners();
  }


  UnmodifiableSetView<StopArea> get loadingStopAreas
    => UnmodifiableSetView(_loadingStopAreas);


  UnmodifiableSetView<ProcessedElement>? elementsOf(StopArea stopArea) {
    return _stopAreaToElementsMapping[stopArea]?.filteredElements;
  }

  /// Get a set of all loaded and filtered osm elements
  /// Since this returns a Set this won't contain any duplicates.

  UnionSet<ProcessedElement> get extractedOsmElements {
    // this set won't contain duplicated osm elements
    // since a processed element has a custom equality function based on the underlying osm element
    return UnionSet.from(_stopAreaToElementsMapping.values.map(
      (list) => list.filteredElements)
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
        final osmElements = await _osmElementQueryHandler.queryByBBox(stopArea.bounds);
        // extract elements
        _stopAreaToElementsMapping[stopArea] = await ElementPool.extractFrom(
          osmElements: osmElements,
          filters: _buildFilters(stopArea),
        );
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
    // find the corresponding stop area
    final relatedStopArea = _stopAreaToElementsMapping.entries.firstWhere(
      (entry) => entry.value.allElements.contains(proxyElement),
    ).key;

    final uploadApi = OSMElementUploadAPI(
      mapFeatureCollection: _mapFeatureCollection,
      stopArea: relatedStopArea,
      authenticatedUser: authenticatedUser,
      changesetLocale: locale.languageCode
    );

    try {
      await proxyElement.publish(uploadApi);
      // refilter on success
      // because an elements condition can start matching when another element's tags change
      // or can stop matching because all questions are answered an no condition matches anymore
      await _stopAreaToElementsMapping[relatedStopArea]?.filter(
        _buildFilters(relatedStopArea),
      );
    }
    finally {
      uploadApi.dispose();
      notifyListeners();
    }
  }


  List<ElementFilter> _buildFilters(StopArea stopArea) => [
    AreaFilter(
      area: stopArea,
    ),
    QuestionFilter(
      questionCatalog: _questionCatalog,
    ),
  ];


  @override
  void dispose() {
    _osmElementQueryHandler.dispose();
    super.dispose();
  }
}
