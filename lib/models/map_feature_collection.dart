import 'dart:collection';

import 'package:osm_api/osm_api.dart' hide OSMElementType;
import '/models/osm_element_type.dart';

import '/models/map_feature.dart';

class MapFeatureCollection extends ListBase<MapFeature> {
  final List<MapFeature> mapFeatureCollection;

  MapFeatureCollection(this.mapFeatureCollection);

  @override
  int get length => mapFeatureCollection.length;


  @override
  set length(int newLength) {
    mapFeatureCollection.length = newLength;
  }

  @override
  MapFeature operator [](int index) => mapFeatureCollection[index];

  @override
  void operator []=(int index, MapFeature value) {
    mapFeatureCollection[index] = value;
  }

  factory MapFeatureCollection.fromJson(List<Map<String, dynamic>> json) {
    final elementList = List<MapFeature>.unmodifiable(
      json.map<MapFeature>(MapFeature.fromJSON)
    );
    return MapFeatureCollection(elementList);
  }

  /// Compare the elements of this Map Feature Collection with given OSM element
  /// and return the best matching Map Feature Template.

  MapFeature? getMatchingFeature (OSMElement osmElement){
    MapFeature? bestMatch;
    int score = 0;

    for (final MapFeature mapFeature in mapFeatureCollection) {
      try {
        final matchingCondition = mapFeature.conditions.firstWhere((condition) {
          return condition.matches(
            osmElement.tags,
            typeFromOSMElement(osmElement)
          );
        });
        // Check if the newly matched map feature has more matching tags than the previously matched map feature
        final newScore = matchingCondition.osmTags.length;
        if (newScore > score) {
          score = newScore;
          bestMatch = mapFeature;
        }
      }
      on StateError {
        // Continue when no matching condition is found.
      }
    }
    return bestMatch;
  }
}
