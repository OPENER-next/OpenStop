import 'package:flutter/material.dart';

import '/models/answer.dart';
import '/models/question_input.dart';
import '/widgets/question_inputs/string_input.dart';
import '/widgets/question_inputs/bool_input.dart';
import '/widgets/question_inputs/duration_input.dart';
import '/widgets/question_inputs/list_input.dart';
import '/widgets/question_inputs/number_input.dart';
import '/widgets/question_inputs/opening_hours_input.dart';


abstract class QuestionInputWidget extends StatefulWidget {

  /// The [QuestionInput] from which the view is constructed.

  final QuestionInput questionInput;


  /// A controller holding the currently selected/entered [Answer].

  final AnswerController? controller;


  const QuestionInputWidget(
    this.questionInput,
    { this.controller, Key? key }
  ) : super(key: key);


  factory QuestionInputWidget.fromQuestionInput(
    QuestionInput questionInput,
    { AnswerController? controller, Key? key }
  ) {
    switch (questionInput.type) {
      case 'Bool': return BoolInput(questionInput, controller: controller);
      case 'Number': return NumberInput(questionInput, controller: controller);
      case 'String': return StringInput(questionInput, controller: controller);
      case 'List': return ListInput(questionInput, controller: controller);
      case 'Duration': return DurationInput(questionInput, controller: controller);
      case 'OpeningHours': return OpeningHoursInput(questionInput, controller: controller);
      default: throw TypeError();
    }
  }
}


abstract class QuestionInputWidgetState extends State<QuestionInputWidget> {}


class AnswerController<T> extends ChangeNotifier {
  Answer<T>? _answer;

  AnswerController({
    Answer<T>? initialAnswer
  }) : _answer = initialAnswer;


  Answer<T>? get answer => _answer;


  set answer(Answer<T>? value) {
    if (value != _answer) {
      _answer = value;
      notifyListeners();
    }
  }


  void clear() {
    if (_answer != null) {
      _answer = null;
      notifyListeners();
    }
  }


  void hasAnswer() => answer != null;
}
