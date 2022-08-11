import 'package:flutter/material.dart';
import 'package:community_material_icon/community_material_icon.dart';

import '/models/osm_element_type.dart';
import '/models/osm_matcher.dart';
import '/commons/custom_icons.dart';


class MapFeature with OsmMatcher {
  final String name;

  final IconData icon;

  @override
  final Map<String, dynamic> osmTags;

  @override
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
}
