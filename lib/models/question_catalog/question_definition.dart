import 'dart:convert';

import 'package:crypto/crypto.dart';

import '/models/element_conditions/element_condition.dart';
import 'answer_definition.dart';

/// A [QuestionDefinition] is a bundle of data that describes the question that will be shown, when it will be shown
/// as well as what its possible answer and outcome is.
///
/// Its equality function is solely based on the [id] which is a hash of the untranslated JSON entry
/// the question is defined by (see [QuestionDefinition.idFromJSON]).
///
/// This means the [id] stays the same across app restarts, language changes and app updates
/// as long as the definition of the question itself doesn't change.
/// It is therefore used to persist answers.

class QuestionDefinition {
  final String id;

  final String name;

  final String question;

  final String description;

  final List<String> images;

  final List<ElementCondition> conditions;

  final AnswerDefinition answer;

  const QuestionDefinition({
    required this.id,
    required this.name,
    required this.question,
    required this.conditions,
    required this.answer,
    this.description = '',
    this.images = const [],
  });

  /// Create a question from its (translated) [json] entry.
  ///
  /// The [id] should be calculated via [idFromJSON] from the untranslated entry.

  factory QuestionDefinition.fromJSON(String id, Map<String, dynamic> json) {
    final Map<String, dynamic> question = json['question'];
    return QuestionDefinition(
      id: id,
      name: question['name'],
      description: question['description'] ?? '',
      images: (question['image'] as List?)?.cast<String>() ?? [],
      question: question['text'],
      conditions: (json['conditions'] as List)
          .cast<Map<String, dynamic>>()
          .map<ElementCondition>(ElementCondition.fromJSON)
          .toList(growable: false),
      answer: AnswerDefinition.fromJSON(json['answer']),
    );
  }

  /// Calculates the identifier of a question from its untranslated JSON entry.
  ///
  /// Translations must not be resolved yet, otherwise the id would change with the language.

  static String idFromJSON(Map<String, dynamic> untranslatedJson) {
    return md5.convert(utf8.encode(jsonEncode(untranslatedJson))).toString();
  }

  @override
  String toString() {
    return 'QuestionDefinition(id: $id, name: $name, question: $question, description: $description, images: $images, conditions: $conditions, answer: $answer)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is QuestionDefinition && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
