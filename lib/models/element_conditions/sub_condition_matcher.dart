import 'package:flutter/foundation.dart';

import '/models/element_conditions/tag_value_matcher.dart';
import '/models/element_variants/base_element.dart';
import '/models/osm_element_type.dart';
import 'element_condition.dart';

/// Base class for individual condition statements.
/// Together sub conditions form a condition.

abstract class SubCondition<T> extends Matcher<T, ProcessedElement> {
  const SubCondition(super.characteristics);
}

/// Check whether certain tags match the tags of the element.

class TagsSubCondition extends SubCondition<Map<String, TagValueMatcher>> {
  const TagsSubCondition(super.characteristics);

  /// Strings starting and ending with `/` are interpreted as regular expressions.
  ///
  /// Currently setting RegEx flags is not supported and case sensitive matching is enabled.

  TagsSubCondition.fromJson(Map<String, dynamic> json) : super(json.map(_buildMatchersFromJSON));

  static MapEntry<String, TagValueMatcher> _buildMatchersFromJSON(String key, dynamic value) {
    return MapEntry(
      key,
      value is Iterable
          ? MultiValueMatcher(value.map(_buildMatcherFromJSON).toList(growable: false))
          : _buildMatcherFromJSON(value),
    );
  }

  static TagValueMatcher _buildMatcherFromJSON(dynamic conditionValue) {
    if (conditionValue == true) {
      return const NotEmptyValueMatcher();
    } else if (conditionValue == false) {
      return const EmptyValueMatcher();
    }
    // parse RegExp from String
    else if (conditionValue is String &&
        conditionValue.length > 1 &&
        conditionValue[0] == '/' &&
        conditionValue[conditionValue.length - 1] == '/') {
      try {
        final regex = RegExp(conditionValue.substring(1, conditionValue.length - 1));
        return RegexValueMatcher(regex);
      } on FormatException {
        debugPrint('RegEx parsing for "$conditionValue" from question catalog failed.');
      }
    }
    return StringValueMatcher(conditionValue);
  }

  @override
  bool matches(sample) {
    return characteristics.entries.every((tagCondition) {
      final tagValue = sample.tags[tagCondition.key];
      return tagCondition.value.matches(tagValue);
    });
  }
}

/// Check whether one of the given element types match the type of the element.

class ElementTypeSubCondition extends SubCondition<List<OSMElementType>> {
  const ElementTypeSubCondition(super.characteristics);

  ElementTypeSubCondition.fromJson(dynamic json)
    : super(_buildEnumTypes(json).toList(growable: false));

  static Iterable<OSMElementType> _buildEnumTypes(dynamic json) sync* {
    if (json is Iterable) {
      for (final type in json) {
        yield (type as String).toOSMElementType();
      }
    } else if (json is String) {
      yield json.toOSMElementType();
    }
  }

  @override
  bool matches(sample) {
    return characteristics.isEmpty || characteristics.contains(sample.specialType);
  }
}

/// Check whether certain conditions match any parent of the given element.

class ChildSubCondition extends SubCondition<List<ElementCondition>> {
  const ChildSubCondition(super.characteristics);

  ChildSubCondition.fromJson(List<Map<String, dynamic>> json)
    : super(json.map(ElementCondition.fromJSON).toList(growable: false));

  @override
  bool matches(sample) {
    return characteristics.isEmpty ||
        characteristics.any((condition) => sample.children.any(condition.matches));
  }
}

/// Check whether certain conditions match any child of the given element.

class ParentSubCondition extends SubCondition<List<ElementCondition>> {
  const ParentSubCondition(super.characteristics);

  ParentSubCondition.fromJson(List<Map<String, dynamic>> json)
    : super(json.map(ElementCondition.fromJSON).toList(growable: false));

  @override
  bool matches(sample) {
    return characteristics.isEmpty ||
        characteristics.any((condition) => sample.parents.any(condition.matches));
  }
}

/// Check whether a certain condition part does **not** match the given element.

class NegatedSubCondition<T extends SubCondition> extends SubCondition<T> {
  const NegatedSubCondition(super.characteristics);

  @override
  bool matches(sample) {
    return !characteristics.matches(sample);
  }
}
