import '/models/osm_element_type.dart';

mixin OsmMatcher {
  List<OSMElementType> get osmElements;
  Map<String, dynamic> get osmTags;


  /// Check whether this map feature matches the given data.

  bool matches(Map<String, String> tags, OSMElementType type) =>
      matchesTags(tags) && matchesElement(type);


  /// Check whether the tags of this map feature matches the given tags.

  bool matchesTags(Map<String, String> tags) =>
      osmTags.entries.every((entry) {
        final value = tags[entry.key];
        if (entry.value is Iterable) {
          return entry.value.any(
                  (condValue) => _conditionCheck(condValue, value)
          );
        }
        else {
          return _conditionCheck(entry.value, value);
        }
      });


  /// Check whether the element types of this map feature matches the given element type.

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
}
