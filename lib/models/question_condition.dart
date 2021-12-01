import '/models/osm_element_type.dart';

/// This class holds the conditions that specify if a [Question] should be asked.

class QuestionCondition {

  final Map<String, dynamic> osmTags;

  final List<OSMElementType> osmElements;

  const QuestionCondition(this.osmTags, this.osmElements);

  factory QuestionCondition.fromJSON(Map<String, dynamic> json) {
    List<OSMElementType> osmElement = [];
    if (json['osm_element'] is List) {
      osmElement.addAll(json['osm_element']
      .cast<String>()
      .map<OSMElementType>((String e) => e.toOSMElementType()));
    }
    else if (json['osm_element'] is String) {
      osmElement.add((json['osm_element'] as String).toOSMElementType());
    }

    return QuestionCondition(
      json['osm_tags'] ?? <String, dynamic>{},
      osmElement
    );
  }


  /// Check whether this condition matches the given data.

  bool matches(Map<String, String> tags, OSMElementType type) =>
    matchesTags(tags) && matchesElement(type);


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


  @override
  String toString() => 'QuestionCondition(osmTags: $osmTags, osmElements: $osmElements)';
}
