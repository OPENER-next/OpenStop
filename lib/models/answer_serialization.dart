import '/models/answer.dart';
import '/models/panoramax_photo.dart';
import '/models/question_catalog/answer_definition.dart';

/// Serializes an [Answer] without its definition.
///
/// The definition is restored from the question catalog, see [answerFromJson].

Map<String, dynamic> answerToJson(Answer answer) => switch (answer) {
  StringAnswer(:final value) => {'type': 'String', 'value': value},
  NumberAnswer(:final value) => {'type': 'Number', 'value': value},
  BoolAnswer(:final value) => {'type': 'Bool', 'value': value},
  ListAnswer(:final value) => {'type': 'List', 'value': value},
  MultiListAnswer(:final value) => {'type': 'MultiList', 'value': value},
  DurationAnswer(:final value) => {'type': 'Duration', 'value': value.inSeconds},
  PhotoAnswer(:final value) => {
    'type': 'Photo',
    'value': [for (final photo in value) photo.toJson()],
  },
  _ => throw UnsupportedError('Cannot serialize answer of type ${answer.runtimeType}'),
};

/// Restores an answer serialized with [answerToJson] for the given [definition].
///
/// Returns `null` if the answer doesn't fit the definition (anymore) or is malformed.
/// Photos whose files no longer exist are dropped.

Answer? answerFromJson(AnswerDefinition definition, Map<String, dynamic> json) {
  try {
    final value = json['value'];
    return switch ((json['type'], definition)) {
      ('String', final StringAnswerDefinition d) => StringAnswer(definition: d, value: value as String),
      ('Number', final NumberAnswerDefinition d) => NumberAnswer(definition: d, value: value as String),
      ('Bool', final BoolAnswerDefinition d) => BoolAnswer(definition: d, value: value as bool),
      ('List', final ListAnswerDefinition d) => ListAnswer(definition: d, value: value as int),
      ('MultiList', final ListAnswerDefinition d) => MultiListAnswer(
        definition: d,
        value: (value as List).cast<int>().toList(),
      ),
      ('Duration', final DurationAnswerDefinition d) => DurationAnswer(
        definition: d,
        value: Duration(seconds: value as int),
      ),
      ('Photo', final PhotoAnswerDefinition d) => PhotoAnswer(
        definition: d,
        value: (value as List)
            .cast<Map<String, dynamic>>()
            .map(PanoramaxPhoto.fromJson)
            .whereType<PanoramaxPhoto>()
            .toList(),
      ),
      _ => null,
    };
  } on TypeError {
    return null;
  }
}
