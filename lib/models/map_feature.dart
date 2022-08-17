import 'package:flutter/material.dart';
import 'package:community_material_icon/community_material_icon.dart';

import '/models/osm_condition.dart';
import '/models/osm_element_type.dart';
import '/commons/custom_icons.dart';

/// A map feature defines how certain elements will be represented and descriped.

class MapFeature {
  final String name;

  final IconData icon;

  final List<OsmCondition> conditions;

  const MapFeature({
    required this.name,
    required this.icon,
    required this.conditions,
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
      conditions: json['conditions']
      // https://github.com/dart-lang/linter/issues/3226
      // ignore: unnecessary_lambdas
          ?.map<OsmCondition>((e) =>OsmCondition.fromJSON(e))
          ?.toList(growable: false) ?? [],
    );
  }
  @override
  String toString() =>
      'MapFeature(name: $name, icon: $icon, conditions: $conditions)';
}
