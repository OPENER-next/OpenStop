import 'package:flutter/material.dart';
import '/widgets/questions/question_input_view.dart';
import '/models/question_input.dart';


class OpeningHoursInput extends QuestionInputView {
  OpeningHoursInput(
    QuestionInput questionInput,
    { void Function(Map<String, String>)? onChange, Key? key }
  ) : super(questionInput, onChange: onChange, key: key);

  @override
  _OpeningHoursInputState createState() => _OpeningHoursInputState();
}


class _OpeningHoursInputState extends State<OpeningHoursInput> {
  @override
  Widget build(BuildContext context) {
    return Text('Dummy');
  }
}