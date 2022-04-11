import 'package:flutter/material.dart';
import 'question_input_widget.dart';
import '/models/question_input.dart';


class OpeningHoursInput extends QuestionInputWidget {
  const OpeningHoursInput({
    required QuestionInput definition,
    required AnswerController controller,
    Key? key
  }) : super(definition: definition, controller: controller, key: key);


  @override
  Widget build(BuildContext context) {
    return const Text('Dummy');
  }
}
