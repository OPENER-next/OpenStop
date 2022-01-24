import 'dart:collection';

import 'package:osm_api/osm_api.dart';
import '/models/osm_element_type.dart' as local;

import '/models/map_feature_template.dart';

class MapTemplateFeatureCollection extends ListBase<MapFeatureTemplate> {
  final List<MapFeatureTemplate> elements;

  MapTemplateFeatureCollection(this.elements);

  @override
  int get length => elements.length;


  @override
  set length(int newLength) {
    elements.length = newLength;
  }

  @override
  MapFeatureTemplate operator [](int index) => elements[index];

  @override
  void operator []=(int index, MapFeatureTemplate value) {
    elements[index] = value;
  }

  factory MapTemplateFeatureCollection.fromJson(List<Map<String, dynamic>> json) {
    final elementList = json.map<MapFeatureTemplate>(
            (jsonOSMObject) => MapFeatureTemplate.fromJSON(jsonOSMObject)
    ).toList();
    return MapTemplateFeatureCollection(elementList);
  }

  MapFeatureTemplate? getMatchingFeature (OSMElement osmElement){
    MapFeatureTemplate? bestMatch;
    int score = 0;

    for (final MapFeatureTemplate object in elements) {
      if (object.matches(osmElement.tags, local.typeFromOSMElement(osmElement))) {
        final newScore = object.osmTags.length;
        if (newScore > score) {
          score = newScore;
          bestMatch = object;
        }
      }
    }
    return bestMatch;
  }
}
