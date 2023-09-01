import 'dart:collection';

import 'package:flutter/material.dart';

import '/models/osm_element_type.dart';
import '/models/element_conditions/element_condition.dart';
import '/models/element_conditions/sub_condition_matcher.dart';
import '/models/element_conditions/tag_value_matcher.dart';
import '/models/element_variants/base_element.dart';
import 'map_feature_definition.dart';
import 'map_feature_representation.dart';


abstract final class MapFeatures {

  /// Compare the elements of this Map Feature Collection with given OSM element
  /// and return the best matching Map Feature Template.
  ///
  /// If not matching [MapFeatureDefinition] can be found a dummy [MapFeatureRepresentation] is returned.

  static MapFeatureRepresentation getForElement (ProcessedElement osmElement) {
    MapFeatureDefinition? bestMatch;
    int score = 0;

    for (final MapFeatureDefinition mapFeature in _list) {
      final matchingCondition = mapFeature.matchesBy(osmElement);
      if (matchingCondition != null) {
        // Check if the newly matched map feature has more matching tags than the previously matched map feature
        final newScore = _calcConditionScore(matchingCondition);
        if (newScore > score) {
          score = newScore;
          bestMatch = mapFeature;
        }
      }
    }

    if (bestMatch != null) {
      return bestMatch.resolve(osmElement);
    }
    else {
      // construct dummy MapFeatureRepresentation
      return MapFeatureRepresentation.fromElement(element: osmElement);
    }
  }

  /// Calculate a simple score for a condition in order to prioritize one map feature over another.
  /// Currently this only counts the number of tags the main tag condition has.

  static int _calcConditionScore(ElementCondition condition) {
    return condition.characteristics.fold<int>(0, (value, cond) {
      if (cond is TagsSubCondition) return value + cond.characteristics.length;
      return value;
    });
  }

  static final UnmodifiableListView<MapFeatureDefinition> definitions = UnmodifiableListView(_list);

  /// Defines all map features with their names, icons and conditions.
  // TODO: make whole list const one day when https://github.com/dart-lang/language/issues/1048 is implemented
  static final _list = <MapFeatureDefinition>[

  ];
}
