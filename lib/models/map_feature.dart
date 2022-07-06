import 'package:flutter/material.dart';
import 'package:community_material_icon/community_material_icon.dart';

import '/models/osm_element_type.dart';
import '/commons/custom_icons.dart';


class MapFeature {
  final String name;

  final IconData icon;

  final Map<String, dynamic> osmTags;

  final List<OSMElementType> osmElements;

  const MapFeature({
    required this.name,
    required this.icon,
    required this.osmTags,
    required this.osmElements,
  });

  factory MapFeature.fromJSON(Map<String, dynamic> json) {
    final List<OSMElementType> osmElement = [];
    if (json['osm_element'] is List) {
      osmElement.addAll(json['osm_element']
          .cast<String>()
          .map<OSMElementType>((String e) => e.toOSMElementType()));
    }
    else if (json['osm_element'] is String) {
      osmElement.add((json['osm_element'] as String).toOSMElementType());
    }

    return MapFeature(
      name: json['name'],
      icon: customIcons[json['icon']] ?? CommunityMaterialIcons.cancel,
      osmTags: json['osm_tags']?.cast<String, dynamic>() ?? <String, dynamic>{},
      osmElements: osmElement,
    );
  }
  @override
  String toString() =>
      'MapFeature(name: $name, icon: $icon, osm_tags: $osmTags, osm_element: $osmElements)';

  /// Check whether this map feature matches the given data.

  bool matches(Map<String, String> tags, OSMElementType type) =>
      matchesTags(tags) && matchesElement(type);


  /// Check whether the tags of this map feature matches the given tags.

  bool matchesTags(Map<String, String> tags) =>
      osmTags.entries.every((entry) {
        final value = tags[entry.key];
        if (entry.value is Iterable) {
          return entry.value.any(
                  (condValue) => _conditionCheck(condValue, value)
          );
        }
        else {
          return _conditionCheck(entry.value, value);
        }
      });


  /// Check whether the element types of this map feature matches the given element type.

  bool matchesElement(OSMElementType type) =>
      osmElements.isEmpty || osmElements.contains(type);


  /// Returns true:
  /// - if the condition value is true and the actual value is present (not null)
  /// - if the condition value is false and the actual value is not present (is null)
  /// - if the condition value is equal to the actual value

  bool _conditionCheck (dynamic conditionValue, String? actualValue) {
    if (conditionValue is bool) {
      return (actualValue is String) == conditionValue;
    }
    return actualValue == conditionValue;
  }
}
