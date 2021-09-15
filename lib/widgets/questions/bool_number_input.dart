import 'package:flutter/material.dart';
import '/widgets/questions/question_input_view.dart';
import '/models/question_input.dart';


class BoolNumberInput extends QuestionInputView {
  BoolNumberInput(
    QuestionInput questionInput,
    { void Function(Map<String, String>)? onChange, Key? key }
  ) : super(questionInput, onChange: onChange, key: key);

  @override
  _BoolNumberInputState createState() => _BoolNumberInputState();
}


class _BoolNumberInputState extends State<BoolNumberInput> {
  @override
  Widget build(BuildContext context) {
    return Text('Dummy');
  }
}