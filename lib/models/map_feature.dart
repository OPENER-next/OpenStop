import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

import '/commons/custom_icons.dart';
import '/models/element_variants/base_element.dart';
import '/models/element_conditions/element_condition.dart';
import '/models/expression_handler.dart';

/// A map feature defines how certain elements will be represented and described.

class MapFeature with ExpressionHandler {
  final String name;

  final IconData icon;

  /// A expression that might reference OSM tags/keys via `$`.
  ///
  /// Example: `["JOIN", "\n", "$name", "$type"]`

  final List<dynamic> labelTemplate;

  final List<ElementCondition> conditions;

  const MapFeature({
    required this.name,
    required this.icon,
    required this.conditions,
    this.labelTemplate = const [],
  });

  factory MapFeature.fromJSON(Map<String, dynamic> json) {
    return MapFeature(
      name: json['name'],
      icon: customIcons[json['icon']] ?? MdiIcons.cancel,
      labelTemplate: json['label_template'] ?? [],
      conditions: json['conditions']
        ?.cast<Map<String, dynamic>>()
        .map<ElementCondition>(ElementCondition.fromJSON)
        .toList(growable: false) ?? [],
    );
  }


  /// If any tag template could not be resolved the entire string part will be dropped

  String? labelByElement(BaseElement element) {
    if (labelTemplate.isEmpty) {
      return null;
    }
    final result = evaluateExpression(labelTemplate, (name) sync* {
      final value =  element.tags[name];
      if (value != null) {
        yield value;
      }
    });
    // replace \n with new line character
    return result?.replaceAll(r'\n' ,'\n');
  }


  @override
  String toString() =>
    'MapFeature(name: $name, icon: $icon, conditions: $conditions, labelTemplate: $labelTemplate)';
}
