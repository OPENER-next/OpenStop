import 'package:flutter/foundation.dart';

import '/models/osm_element_type.dart';
import 'element_variants/base_element.dart';

/// This class holds the conditions that specify if a [Question] should be asked.

class OsmCondition {

  final Map<String, dynamic> osmTags;

  final List<OSMElementType> osmElementTypes;

  final List<OsmCondition> childElements;

  final List<OsmCondition> parentElements;

  const OsmCondition({
    this.osmTags = const {},
    this.osmElementTypes = const [],
    this.childElements = const [],
    this.parentElements = const [],
  });


  /// Strings starting and ending with `/` are interpreted as regular expressions.
  ///
  /// Currently setting RegEx flags is not supported and case sensitive matching is enabled.

  factory OsmCondition.fromJSON(Map<String, dynamic> json) {
    final Map<String, dynamic>? tags = json['osm_tags']
      ?.cast<String, dynamic>()
      .map((key, value) {
        if (value is Iterable) {
          value = value.map((v) => _parseAsRegex(v) ?? v).toList();
        }
        else {
          value = _parseAsRegex(value) ?? value;
        }
        return MapEntry(key, value);
      });

    final List<OSMElementType> osmElement;
    if (json['osm_element'] is List) {
      osmElement = json['osm_element']
      .cast<String>()
      .map<OSMElementType>((String e) => e.toOSMElementType())
      .toList();
    }
    else {
      osmElement = [
        // "as String" required since extension methods are resolved statically
        if (json['osm_element'] is String) (json['osm_element'] as String).toOSMElementType(),
      ];
    }

    final List<OsmCondition>? child = json['child']
      ?.cast<Map<String, dynamic>>()
      .map<OsmCondition>(OsmCondition.fromJSON)
      .toList(growable: false);

    final List<OsmCondition>? parent = json['parent']
      ?.cast<Map<String, dynamic>>()
      .map<OsmCondition>(OsmCondition.fromJSON)
      .toList(growable: false);

    return OsmCondition(
      osmTags: tags ?? <String, dynamic>{},
      osmElementTypes: osmElement,
      childElements: child ?? [],
      parentElements: parent ?? [],
    );
  }

  /// Strings starting and ending with `/` are interpreted as regular expressions.
  ///
  /// Currently setting RegEx flags is not supported and case sensitive matching is enabled.
  ///
  /// Returns null if the given value could not be parsed as a [RegExp].

  static RegExp? _parseAsRegex(dynamic value) {
    if (value is String && value.isNotEmpty && value[0] == '/' && value[value.length - 1] == '/') {
      try {
        return RegExp(value.substring(1, value.length - 1));
      }
      on FormatException {
        debugPrint('RegEx parsing from question catalog failed.');
      }
    }
    return null;
  }


  /// Check whether this condition matches the given element.

  bool matches(ProcessedElement element) {
    return matchesTags(element.tags) &&
           matchesElementType(element.specialType) &&
           matchesChild(element.children) &&
           matchesParent(element.parents);
  }


  /// Check whether the tags of this condition matches the given tags.

  bool matchesTags(Map<String, String> tags) =>
    osmTags.entries.every((tagCondition) {
      final value = tags[tagCondition.key];
      if (tagCondition.value is Iterable) {
        return tagCondition.value.any(
          (condValue) => _conditionCheck(condValue, value)
        );
      }
      else {
        return _conditionCheck(tagCondition.value, value);
      }
    });


  /// Check whether the element types of this condition matches the given element type.

  bool matchesElementType(OSMElementType type) =>
    osmElementTypes.isEmpty || osmElementTypes.contains(type);


  /// Check whether any parent condition matches the parents of the given element.

  bool matchesChild(Iterable<ChildElement> children) {
    return childElements.isEmpty ||
      childElements.any((condition) => children.any(condition.matches));
  }


  /// Check whether any child condition matches the children of the given element.

  bool matchesParent(Iterable<ParentElement> parents) {
    return parentElements.isEmpty ||
      parentElements.any((condition) => parents.any(condition.matches));
  }


  /// Returns true:
  /// - if the condition value is true and the actual value is present (not null)
  /// - if the condition value is false and the actual value is not present (is null)
  /// - if the condition value is a regular expression which matches the actual value
  /// - if the condition value is equal to the actual value

  bool _conditionCheck (dynamic conditionValue, String? actualValue) {
    if (conditionValue is bool) {
      return (actualValue is String) == conditionValue;
    }
    else if (conditionValue is RegExp && actualValue is String) {
      return conditionValue.hasMatch(actualValue);
    }
    return actualValue == conditionValue;
  }

  @override
  String toString() => 'QuestionCondition(osmTags: $osmTags, osmElementTypes: $osmElementTypes, childElements: $childElements, parentElements: $parentElements)';
}
