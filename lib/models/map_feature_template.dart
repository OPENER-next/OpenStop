import 'package:flutter/material.dart';

import '/models/osm_element_type.dart';
import '/commons/custom_icons.dart';


class MapFeatureTemplate {
  final String name;

  final IconData? icon;

  final Map<String, String> osmTags;

  final OSMElementType osmElement;

  const MapFeatureTemplate({
    required this.name,
    required this.icon,
    required this.osmTags,
    required this.osmElement
  });

  factory MapFeatureTemplate.fromJSON(Map<String, dynamic> json) =>
      MapFeatureTemplate(
        name: json['name'],
        icon: customIcons[json['icon']],
        osmTags: json['osm_tags']?.cast<String, String>() ?? <String, String>{},
        osmElement: (json['osm_element'] as String).toOSMElementType(),
      );

  @override
  String toString() =>
      'TemplateOSMObject(name: $name, icon: $icon, osm_tags: $osmTags, osm_element: $osmElement)';

  /// Check whether this condition matches the given data.

  bool matches(Map<String, String> tags, OSMElementType type) =>
      matchesElement(type) && matchesTags(tags);


  /// Check whether the tags of this condition matches the given tags.

  bool matchesTags(Map<String, String> tags) =>
      osmTags.entries.every((entry) => tags[entry.key] == entry.value);


  /// Check whether the element types of this condition matches the given element type.

  bool matchesElement(OSMElementType type) =>
      osmElement == type;
}
