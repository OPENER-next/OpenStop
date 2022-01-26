import 'package:flutter/material.dart';
import 'package:community_material_icon/community_material_icon.dart';

import '/models/osm_element_type.dart';
import '/commons/custom_icons.dart';


class MapFeature {
  final String name;

  final IconData? icon;

  final Map<String, String> osmTags;

  final OSMElementType osmElement;

  const MapFeature({
    required this.name,
    required this.icon,
    required this.osmTags,
    required this.osmElement,
  });

  factory MapFeature.fromJSON(Map<String, dynamic> json) =>
      MapFeature(
        name: json['name'],
        icon: customIcons[json['icon']] ?? CommunityMaterialIcons.cancel,
        osmTags: json['osm_tags']?.cast<String, String>() ?? <String, String>{},
        osmElement: (json['osm_element'] as String).toOSMElementType(),
      );

  @override
  String toString() =>
      'MapFeature(name: $name, icon: $icon, osm_tags: $osmTags, osm_element: $osmElement)';

  /// Check whether this map feature matches the given data.

  bool matches(Map<String, String> tags, OSMElementType type) =>
      matchesElement(type) && matchesTags(tags);


  /// Check whether the tags of this map feature matches the given tags.

  bool matchesTags(Map<String, String> tags) =>
      osmTags.entries.every((entry) => tags[entry.key] == entry.value);


  /// Check whether the element types of this map feature matches the given element type.

  bool matchesElement(OSMElementType type) =>
      osmElement == type;
}
