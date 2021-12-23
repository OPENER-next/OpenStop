import 'dart:collection';

import 'question.dart';

/// This class resembles a list of questions.

class QuestionCatalog extends ListBase<Question> {
  final List<Question> questions;

  QuestionCatalog(this.questions);

  @override
  int get length => questions.length;


  @override
  set length(int newLength) {
    questions.length = newLength;
  }


  @override
  Question operator [](int index) => questions[index];


  @override
  void operator []=(int index, Question value) {
    questions[index] = value;
  }


  factory QuestionCatalog.fromJson(List<Map<String, dynamic>> json) {
    final questionList = json.map<Question>(
      (jsonQuestion) => Question.fromJSON(jsonQuestion)
    ).toList();
    return QuestionCatalog(questionList);
  }
}
