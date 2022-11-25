import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:osm_api/osm_api.dart';

import '/api/osm_element_upload_api.dart';
import '/models/authenticated_user.dart';
import '/models/map_feature_collection.dart';
import '/models/proxy_osm_element.dart';
import '/models/osm_element_type.dart' as special_types;
import '/models/geometric_osm_element.dart';
import '/models/question_catalog/question_catalog.dart';
import '/api/osm_element_query_api.dart';
import '/models/stop_area.dart';

class OSMElementProvider extends ChangeNotifier {

  final _osmElementQueryHandler = OSMElementQueryAPI();

  final _loadingStopAreas = <StopArea>{};

  final _cachedOsmElementsMap = <StopArea, OSMElementBundle>{};

  final _extractedOsmElementsMap = <StopArea, List<GeometricOSMElement>>{};

  QuestionCatalog _questionCatalog;

  MapFeatureCollection _mapFeatureCollection;

  OSMElementProvider({
    required QuestionCatalog questionCatalog,
    required MapFeatureCollection mapFeatureCollection
  }) :
    _questionCatalog = questionCatalog,
    _mapFeatureCollection = mapFeatureCollection;

  /// Used to update all dependency injections.
  /// Updating th question catalog will re-extract/filter all osm elements.

  void update({
    required QuestionCatalog questionCatalog,
    required MapFeatureCollection mapFeatureCollection
  }) async {
    if (questionCatalog != _questionCatalog) {
      _questionCatalog = questionCatalog;
      for (final entry in _cachedOsmElementsMap.entries) {
        final stopArea = entry.key;
        _extractedOsmElementsMap[stopArea] = await _extract(stopArea, entry.value);
      }
      notifyListeners();
    }

    _mapFeatureCollection = mapFeatureCollection;
  }


  UnmodifiableSetView<StopArea> get loadingStopAreas
    => UnmodifiableSetView(_loadingStopAreas);


  UnmodifiableMapView<StopArea, List<GeometricOSMElement>> get extractedOsmElementsMap
    => UnmodifiableMapView(_extractedOsmElementsMap);

  /// Get a set of all loaded osm elements
  /// Since this returns a Set this won't contain any duplicates.

  Set<OSMElement> get osmElements {
    // use set to remove duplicates
    return Set.of(_cachedOsmElementsMap.values.expand<OSMElement>(
      (bundle) => bundle.elements
    ));
  }

  /// Get a set of all loaded and filtered osm elements
  /// Since this returns a Set this won't contain any duplicates.

  Set<GeometricOSMElement> get extractedOsmElements {
    // this set won't contain duplicated osm elements
    // since a geo osm element has a custom equality function based on the underlying osm element
    return Set.of(_extractedOsmElementsMap.values.expand(
      (list) => list)
    );
  }

  /// Check whether a stop area has been loaded and extracted.

  bool stopAreaIsExtracted(StopArea stopArea) => _extractedOsmElementsMap.containsKey(stopArea);


  /// Check whether a stop area has been loaded.

  bool stopAreaIsLoaded(StopArea stopArea) => _cachedOsmElementsMap.containsKey(stopArea);


  /// Check whether a stop area is currently loading.

  bool stopAreaIsLoading(StopArea stopArea) => _loadingStopAreas.contains(stopArea);

  /// Load and extract elements from a given stop area and question catalog.

  Future<void> loadElementsFromStopArea(StopArea stopArea) async {
    if (!stopAreaIsLoading(stopArea) && !stopAreaIsLoaded(stopArea)) {
      _loadingStopAreas.add(stopArea);
      notifyListeners();
      try {
        final osmElements = await _osmElementQueryHandler.queryByBBox(stopArea.bounds);

        _cachedOsmElementsMap[stopArea] = osmElements;
        _extractedOsmElementsMap[stopArea] = await _extract(stopArea, osmElements);
      }
      finally {
        _loadingStopAreas.remove(stopArea);
        notifyListeners();
      }
    }
  }


  Future<List<GeometricOSMElement>> _extract(StopArea stopArea, OSMElementBundle osmElements) {
    // run the operation in a separate thread to avoid blocking the UI
    return compute(
      _extractElements,
      _IsolateContainer(
        questionCatalog: _questionCatalog,
        stopArea: stopArea,
        osmElementBundle: osmElements
      )
    );
  }


  /// Upload the changes made by this questionnaire with the given authenticated user.

  Future<void> upload({
    required ProxyOSMElement osmProxyElement,
    required AuthenticatedUser authenticatedUser,
    required Locale locale
  }) async {
    // find the corresponding stop area
    final relatedStopArea = _extractedOsmElementsMap.entries.firstWhere(
      (entry) => entry.value.any(
        (geoElement) => osmProxyElement.isOther(geoElement.osmElement)
      )).key;

    final uploadApi = OSMElementUploadAPI(
      mapFeatureCollection: _mapFeatureCollection,
      authenticatedUser: authenticatedUser,
      changesetLocale: locale.languageCode
    );

    try {
      final newOsmElement = await uploadApi.updateOsmElement(
        relatedStopArea, osmProxyElement.apply()
      );
      // only update internal osm element when upload was successfully
      _updateOsmElement(newOsmElement);
    }
    finally {
      uploadApi.dispose();
      notifyListeners();
    }
  }


  /// Update cached and stored osm elements by a given osm element.
  /// This will look for an element with the same type and id and replace it with the new element.

  void _updateOsmElement(OSMElement osmElement) {
    final osmElementIsComplete = !_matches(osmElement, _questionCatalog);

    for (final elements in _extractedOsmElementsMap.values) {
      // find first instance of the updated element if any
      final index = elements.indexWhere((element) {
        return element.osmElement.id == osmElement.id &&
               element.osmElement.type == osmElement.type;
      });

      if (index != -1) {
        // remove osm elements where no question matches any more (i.a. all questions have been answered)
        if (osmElementIsComplete) {
          elements.removeAt(index);
        }
        // update/replace old osm element with new one
        else {
          elements[index] = GeometricOSMElement(
            osmElement: osmElement,
            geometry: elements[index].geometry
          );
        }
      }
    }

    for (final osmElementBundle in _cachedOsmElementsMap.values) {
      final Set<OSMElement> elements;
      switch (osmElement.type) {
        case OSMElementType.node:
          elements = osmElementBundle.nodes;
        break;
        case OSMElementType.way:
          elements = osmElementBundle.ways;
        break;
        case OSMElementType.relation:
          elements = osmElementBundle.relations;
        break;
      }

      try {
        final oldElement = elements.firstWhere((element) => element.id == osmElement.id);
        elements.remove(oldElement);
        elements.add(osmElement);
      } on StateError { /* catch element not found */ }
    }
  }


  @override
  void dispose() {
    _osmElementQueryHandler.dispose();
    super.dispose();
  }
}



// This function needs to be defined on a top level to run it via compute in a separate isolate.

List<GeometricOSMElement> _extractElements(_IsolateContainer container) {
  final extractedElements = <GeometricOSMElement>[];

  for (final osmElement in container.osmElementBundle.elements) {
    // filter all osm elements where no question matches
    if (_matches(osmElement, container.questionCatalog)) {
      try {
        final geoElement = GeometricOSMElement.generateFromOSMElement(osmElement, container.osmElementBundle);
        // filter all elements whose geometric center lies outside of the stop area circle
        if (container.stopArea.isPointInside(geoElement.geometry.center)) {
          extractedElements.add(geoElement);
        }
      } catch(error) {
        debugPrint(error.toString());
      }
    }
  }

  return extractedElements;
}


/// Check whether the given [OSMElement] matches any question condition from the [QuestionCatalog].

bool _matches(OSMElement osmElement, QuestionCatalog questionCatalog) {
  return osmElement.tags.isNotEmpty && questionCatalog.any((question) {
    return question.conditions.any((condition) {
      return condition.matches(osmElement.tags, special_types.typeFromOSMElement(osmElement));
    });
  });
}


/// A container to pass multiple arguments to the isolate.

class _IsolateContainer {
  final QuestionCatalog questionCatalog;
  final StopArea stopArea;
  final OSMElementBundle osmElementBundle;

  _IsolateContainer({
    required this.questionCatalog,
    required this.stopArea,
    required this.osmElementBundle,
  });
}
