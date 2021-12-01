import '/models/question_input.dart';


/// A container class that holds answers for a specific question type in a readable form.
/// This is needed since parsing the answer solely from the OSM tags can lead to inconsistencies.
/// Each question input should create and return an appropriate Answer object.

abstract class Answer<T> {
  Answer({
    required this.questionValues,
    required this.answer
  });

  final Map<String, QuestionInputValue> questionValues;

  final T answer;

  Map<String, String> toTagMap();
}


class StringAnswer extends Answer<String> {
  StringAnswer({
    required Map<String, QuestionInputValue> questionValues,
    required String answer
  }) : super(questionValues: questionValues, answer: answer);


  Map<String, String> toTagMap() {
    final tags = questionValues.values.first.osmTags;

    return tags.map((key, value) {
      return MapEntry(
        key,
        value.replaceAll(RegExp(r'%s'), answer)
      );
    });
  }
}


class NumberAnswer extends Answer<double> {
  NumberAnswer({
    required Map<String, QuestionInputValue> questionValues,
    required double answer
  }) : super(questionValues: questionValues, answer: answer);


  Map<String, String> toTagMap() {
    final tags = questionValues.values.first.osmTags;

    return tags.map((key, value) {
      return MapEntry(
        key,
        value.replaceAll(RegExp(r'%s'), answer.toString())
      );
    });
  }
}


class BoolAnswer extends Answer<bool> {
  BoolAnswer({
    required Map<String, QuestionInputValue> questionValues,
    required bool answer
  }) : super(questionValues: questionValues, answer: answer);


  Map<String, String> toTagMap() {
    final tags = questionValues[answer.toString()]?.osmTags;

    if (tags == null) {
      return const <String, String>{};
    }

    return Map.of(tags);
  }
}


class ListAnswer extends Answer<String> {
  ListAnswer({
    required Map<String, QuestionInputValue> questionValues,
    required String answer
  }) : super(questionValues: questionValues, answer: answer);


  Map<String, String> toTagMap() {
    final tags = questionValues[answer]?.osmTags;

    if (tags == null) {
      return const <String, String>{};
    }

    return Map.of(tags);
  }
}