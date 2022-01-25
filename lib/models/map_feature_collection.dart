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
    final elementList = json.map<MapFeature>(
            (jsonOSMObject) => MapFeature.fromJSON(jsonOSMObject)
    ).toList();
    return MapFeatureCollection(elementList);
  }

  /// Compare the elements of this Map Feature Collection with given OSM element and return the best matching Map Feature Template.

  MapFeature? getMatchingFeature (OSMElement osmElement){
    MapFeature? bestMatch;
    int score = 0;

    for (final MapFeature mapFeature in mapFeatureCollection) {
      if (mapFeature.matches(osmElement.tags, typeFromOSMElement(osmElement))) {
        final newScore = mapFeature.osmTags.length;
        if (newScore > score) {
          score = newScore;
          bestMatch = mapFeature;
        }
      }
    }
    return bestMatch;
  }
}
