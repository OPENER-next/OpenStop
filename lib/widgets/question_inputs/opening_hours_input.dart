import 'package:flutter/material.dart';
import 'question_input_widget.dart';
import '/models/question_input.dart';


class OpeningHoursInput extends QuestionInputWidget {
  const OpeningHoursInput(
    QuestionInput questionInput,
    { AnswerController? controller, Key? key }
  ) : super(questionInput, controller: controller, key: key);

  @override
  _OpeningHoursInputState createState() => _OpeningHoursInputState();
}


class _OpeningHoursInputState extends QuestionInputWidgetState {
  @override
  Widget build(BuildContext context) {
    return const Text('Dummy');
  }
}
