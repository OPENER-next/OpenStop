import 'package:flutter/material.dart';

import '/models/question_catalog/answer_definition.dart';
import 'question_input_widget.dart';


class OpeningHoursInput extends QuestionInputWidget {
  const OpeningHoursInput({
    required super.definition,
    required super.controller,
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    return const Text('Dummy');
  }
}
