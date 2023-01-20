import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '/models/osm_condition.dart';
import '/commons/custom_icons.dart';

/// A map feature defines how certain elements will be represented and described.

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
    return MapFeature(
      name: json['name'],
      icon: customIcons[json['icon']] ?? MdiIcons.cancel,
      conditions: json['conditions']
        ?.cast<Map<String, dynamic>>()
        .map<OsmCondition>(OsmCondition.fromJSON)
        .toList(growable: false) ?? [],
    );
  }
  @override
  String toString() =>
      'MapFeature(name: $name, icon: $icon, conditions: $conditions)';
}
