import '/models/osm_element_type.dart';
import '/models/question_condition.dart';
import '/models/question_input.dart';

/// A question is a bundle of data that describes what will be shown, when it will be shown
/// as well as what its input and outcome is.

class Question {
  final int id;

  final String name;

  final String question;

  final String description;

  final List<String> images;

  final bool isProfessional;

  final OSMElementType? osmElement;

  final List<QuestionCondition> conditions;

  final QuestionInput input;

  const Question({
    required this.id,
    required this.name,
    required this.question,
    required this.isProfessional,
    required this.conditions,
    required this.input,
    this.description = '',
    this.images = const [],
    this.osmElement
  });


  factory Question.fromJSON(Map<String, dynamic> json) =>
    Question(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      images: json['image']?.cast<String>() ?? [],
      question: json['question'],
      conditions: json['conditions']
        ?.map<QuestionCondition>(QuestionCondition.fromJSON)
        ?.toList(growable: false) ?? [],
      input: QuestionInput.fromJSON(json['input']) ,
      osmElement: (json['osm_element'] as String?)?.toOSMElementType(),
      isProfessional: json['isProfessional'] ?? false
    );


  @override
  String toString() =>
    'Question(id: $id, name: $name, question: $question, description: $description, images: $images, isProfessional: $isProfessional, osmElement: $osmElement, conditions: $conditions, input: $input)';
}
