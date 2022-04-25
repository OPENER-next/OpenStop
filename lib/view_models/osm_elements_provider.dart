import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:osm_api/osm_api.dart';

import '/models/osm_element_type.dart' as special_types;
import '/models/geometric_osm_element.dart';
import '/models/question_catalog.dart';
import '/api/osm_element_query_api.dart';
import '/models/stop_area.dart';

class OSMElementProvider extends ChangeNotifier {

  final _osmElementQueryHandler = OSMElementQueryAPI();

  final _loadingStopAreas = <StopArea>{};

  final _osmElementsMap = <StopArea, OSMElementBundle>{};

  final _extractedOsmElementsMap = <StopArea, List<GeometricOSMElement>>{};

  OSMElementProvider();


  UnmodifiableSetView<StopArea> get loadingStopAreas
    => UnmodifiableSetView(_loadingStopAreas);


  UnmodifiableMapView<StopArea, OSMElementBundle> get osmElementsMap
    => UnmodifiableMapView(_osmElementsMap);


  UnmodifiableMapView<StopArea, List<GeometricOSMElement>> get extractedOsmElementsMap
    => UnmodifiableMapView(_extractedOsmElementsMap);

  /// Get a set of all loaded osm elements
  /// Since this returns a Set this won't contain any duplicates.

  Set<OSMElement> get osmElements {
    // use set to remove duplicates
    return Set.of(_osmElementsMap.values.expand<OSMElement>(
      (bundle) => bundle.elements
    ));
  }

  /// Get a set of all loaded and filtered osm elements
  /// Since this returns a Set this won't contain any duplicates.

  Set<GeometricOSMElement> get extractedOsmElements {
    // this set won't contain duplicated osm elements
    // since a geo osm element delegates its equality function to the underlying osm element
    return Set.of(_extractedOsmElementsMap.values.expand(
      (list) => list)
    );
  }

  /// Load and extract elements from a given stop area and question catalog.

  void loadAndExtractElements(StopArea stopArea, QuestionCatalog questionCatalog) async {
    if (!_loadingStopAreas.contains(stopArea) && !_osmElementsMap.containsKey(stopArea)) {
      _loadingStopAreas.add(stopArea);
      notifyListeners();
      try {
        final osmElements = await _osmElementQueryHandler.queryByBBox(stopArea.bounds);
        // run the operation in a separate thread to avoid blocking the UI
        final extractedOsmElements = await compute(
          _extractElements,
          _IsolateContainer(
            questionCatalog: questionCatalog,
            stopArea: stopArea,
            osmElementBundle: osmElements
          )
        );
        _osmElementsMap[stopArea] = osmElements;
        _extractedOsmElementsMap[stopArea] = extractedOsmElements;
      }
      catch(error) {
        // TODO: display error.
        debugPrint(error.toString());
      }
      finally {
        _loadingStopAreas.remove(stopArea);
        notifyListeners();
      }
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
        final geoElement = _constructGeometricElement(osmElement, container.osmElementBundle);
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


/// Create a [GeometricOSMElement] from an osm element and a given bundle of sub osm elements.

GeometricOSMElement _constructGeometricElement(OSMElement osmElement, OSMElementBundle elementBundle) {
  switch(osmElement.type) {
    case OSMElementType.node:
      return GeometricOSMElement.generateFromOSMNode(
        osmNode: osmElement as OSMNode
      );
    case OSMElementType.way:
      return GeometricOSMElement.generateFromOSMWay(
        osmWay: osmElement as OSMWay,
        osmNodes: elementBundle.nodes
      );
    case OSMElementType.relation:
      return GeometricOSMElement.generateFromOSMRelation(
        osmRelation: osmElement as OSMRelation,
        osmWays: elementBundle.ways,
        osmNodes: elementBundle.nodes
      );
  }
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
