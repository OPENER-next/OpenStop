import '/models/osm_element_type.dart';
import '/models/osm_matcher.dart';


/// This class holds the conditions that specify if a [Question] should be asked.

class QuestionCondition with OsmMatcher {

  @override
  final Map<String, dynamic> osmTags;

  @override
  final List<OSMElementType> osmElements;

  const QuestionCondition(this.osmTags, this.osmElements);

  factory QuestionCondition.fromJSON(Map<String, dynamic> json) {
    final List<OSMElementType> osmElement = [];
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

  @override
  String toString() => 'QuestionCondition(osmTags: $osmTags, osmElements: $osmElements)';
}
