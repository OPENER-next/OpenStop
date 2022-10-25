import '/models/osm_condition.dart';
import 'answer_definition.dart';

/// A [QuestionDefinition] is a bundle of data that describes the question that will be shown, when it will be shown
/// as well as what its possible answer and outcome is.

class QuestionDefinition {
  final int? id;

  final String name;

  final String question;

  final String description;

  final List<String> images;

  final bool isProfessional;

  final List<OsmCondition> conditions;

  final AnswerDefinition answer;

  const QuestionDefinition({
    required this.id,
    required this.name,
    required this.question,
    required this.isProfessional,
    required this.conditions,
    required this.answer,
    this.description = '',
    this.images = const []
  });


  factory QuestionDefinition.fromJSON(Map<String, dynamic> json) =>
    QuestionDefinition(
      id: json['question']['id'],
      name: json['question']['name'],
      description: json['question']['description'] ?? '',
      images: json['question']['image']?.cast<String>() ?? [],
      question: json['question']['text'],
      conditions: json['conditions']
        // https://github.com/dart-lang/linter/issues/3226
        // ignore: unnecessary_lambdas
        ?.map<OsmCondition>((e) =>OsmCondition.fromJSON(e))
        ?.toList(growable: false) ?? [],
      answer: AnswerDefinition.fromJSON(json['answer']) ,
      isProfessional: json['isProfessional'] ?? false
    );


  @override
  String toString() =>
    'Question(id: $id, name: $name, question: $question, description: $description, images: $images, isProfessional: $isProfessional, conditions: $conditions, answer: $answer)';
}
