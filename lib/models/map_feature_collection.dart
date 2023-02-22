import 'dart:collection';

import '/models/map_feature.dart';
import 'element_coniditions/element_condition.dart';
import 'element_coniditions/sub_condition_matcher.dart';
import 'element_variants/base_element.dart';

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

  MapFeature? getMatchingFeature (ProcessedElement osmElement) {
    MapFeature? bestMatch;
    int score = 0;

    for (final MapFeature mapFeature in mapFeatureCollection) {
      try {
        final matchingCondition = mapFeature.conditions.firstWhere((condition) {
          return condition.matches(osmElement);
        });
        // Check if the newly matched map feature has more matching tags than the previously matched map feature
        final newScore = _calcConditionScore(matchingCondition);
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

  // Calculate a simple score for a condition in order to prioritize one map feature over another.
  // Currently this only counts the number of tags the main tag condition has.

  int _calcConditionScore(ElementCondition condition) {
    return condition.characteristics.fold<int>(0, (value, cond) {
      if (cond is TagsSubCondition) return value + cond.characteristics.length;
      return value;
    });
  }
}
