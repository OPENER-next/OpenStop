import 'package:flutter/widgets.dart';

import '/l10n/app_localizations.g.dart';
import '/models/element_conditions/element_condition.dart';
import '/models/element_variants/base_element.dart';
import 'map_feature_representation.dart';

/// The [tags] argument may be passed to build an element specific label.

typedef MapFeatureLabelConstructor =
    String Function(AppLocalizations locale, Map<String, String> tags);

/// A map feature defines how certain elements will be represented and described.

class MapFeatureDefinition {
  const MapFeatureDefinition({
    required MapFeatureLabelConstructor label,
    required this.icon,
    required this.conditions,
    this.priority = 0,
  }) : _label = label;

  final MapFeatureLabelConstructor _label;

  final IconData icon;

  final List<ElementCondition> conditions;

  /// Value used to sort/prioritize map features when multiple map features match the same element.
  /// Map features with higher values outperform features with lower values.

  final int priority;

  String label(AppLocalizations locale) => _label(locale, const {});

  /// Creates a [MapFeatureRepresentation] based on this [MapFeatureDefinition]
  /// and a given [ProcessedElement].

  MapFeatureRepresentation resolve(ProcessedElement element) {
    assert(
      matches(element),
      'The resolved element does not match the conditions of this MapFeatureDefinition.',
    );

    return MapFeatureRepresentation.fromElement(
      element: element,
      icon: icon,
      label: _label,
    );
  }

  /// Matches the conditions of this [MapFeatureDefinition] against the given element.

  bool matches(ProcessedElement element) {
    return conditions.any((condition) => condition.matches(element));
  }

  /// Matches the conditions of this [MapFeatureDefinition] against the given element.
  /// Returns the first conditions that matches if any.

  ElementCondition? matchesBy(ProcessedElement element) {
    try {
      return conditions.firstWhere((condition) => condition.matches(element));
    } on StateError {
      // Continue when no matching condition is found.
      return null;
    }
  }
}
