import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:osm_api/osm_api.dart';

import '/models/osm_element_type.dart' as special_types;
import '/models/question_catalog.dart';
import '/models/geometric_osm_element.dart';
import '/models/stop_area.dart';

/// This view model only provides elements that match at least one question from the [QuestionCatalog].
/// Additionally the osm elements will be provided as [GeometricOSMElement] which allows easy rendering.

class IncompleteOSMElementProvider extends ChangeNotifier {

  final _loadedStopAreas = <StopArea, List<GeometricOSMElement>>{};

  IncompleteOSMElementProvider();

  UnmodifiableMapView<StopArea, List<GeometricOSMElement>> get loadedStopAreas
    => UnmodifiableMapView(_loadedStopAreas);


  List<GeometricOSMElement> get loadedOsmElements {
    final geoElements = _loadedStopAreas.values.expand((list) => list).toList();
    final osmElements = <OSMElement>{};
    // remove duplicates by osm element
    geoElements.retainWhere((geoElements) => osmElements.add(geoElements.osmElement));
    return geoElements;
  }


  /// Extract all [GeometricOSMElement]s from a bundle of osm elements grouped by [StopArea]s
  /// where at least one question matches.

  void update(Map<StopArea, OSMElementBundle> stopAreaBundle, QuestionCatalog questionCatalog) {
    // TODO: run this method in separate isolate?

    _loadedStopAreas.clear();

    for (final entry in stopAreaBundle.entries) {
      final stopArea = entry.key;
      final elementBundle = entry.value;

      for (final osmElement in elementBundle.elements) {
        // filter all osm elements where no question matches
        if (_matches(osmElement, questionCatalog)) {
          try {
            final geoElement = _constructGeometricElement(osmElement, entry.value);

            _loadedStopAreas.update(stopArea,
              (value) => value..add(geoElement),
              ifAbsent: () => [geoElement]
            );
          } catch(error) {
            print(error);
          }
        }
      }
    }

    notifyListeners();
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
}
