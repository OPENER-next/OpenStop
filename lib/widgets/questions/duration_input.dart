import 'package:flutter/material.dart';
import '/widgets/questions/question_input_view.dart';
import '/models/question_input.dart';


class DurationInput extends QuestionInputView {
  DurationInput(
    QuestionInput questionInput,
    { void Function(Map<String, String>)? onChange, Key? key }
  ) : super(questionInput, onChange: onChange, key: key);

  @override
  _DurationInputState createState() => _DurationInputState();
}


class _DurationInputState extends State<DurationInput> {
  @override
  Widget build(BuildContext context) {
    return Text('Dummy');
  }
}