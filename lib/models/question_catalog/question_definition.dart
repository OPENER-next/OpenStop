import '/models/element_conditions/element_condition.dart';
import 'answer_definition.dart';

/// A [QuestionDefinition] is a bundle of data that describes the question that will be shown, when it will be shown
/// as well as what its possible answer and outcome is.
///
/// Its equality function is solely based on the [runtimeId] which usually is just the list index from the JSON it is stored in.
///
/// This means a [QuestionDefinition] has a unique id for the entire app runtime.

class QuestionDefinition {
  final int runtimeId;

  final String name;

  final String question;

  final String description;

  final List<String> images;

  final bool isProfessional;

  final List<ElementCondition> conditions;

  final AnswerDefinition answer;

  const QuestionDefinition({
    required this.runtimeId,
    required this.name,
    required this.question,
    required this.isProfessional,
    required this.conditions,
    required this.answer,
    this.description = '',
    this.images = const []
  });


  QuestionDefinition.fromJSON(this.runtimeId, Map<String, dynamic> json) :
    name = json['question']['name'],
    description = json['question']['description'] ?? '',
    images = json['question']['image']?.cast<String>() ?? [],
    question = json['question']['text'],
    conditions = json['conditions']
      ?.cast<Map<String, dynamic>>()
      .map<ElementCondition>(ElementCondition.fromJSON)
      .toList(growable: false) ?? [],
    answer = AnswerDefinition.fromJSON(json['answer']) ,
    isProfessional = json['isProfessional'] ?? false;


  @override
  String toString() {
    return 'QuestionDefinition(runtimeId: $runtimeId, name: $name, question: $question, description: $description, images: $images, isProfessional: $isProfessional, conditions: $conditions, answer: $answer)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is QuestionDefinition &&
      other.runtimeId == runtimeId;
  }

  @override
  int get hashCode => runtimeId.hashCode;
}
