import 'package:flutter/material.dart';
import '/widgets/questions/question_input_view.dart';
import '/models/question_input.dart';


class BoolNumberInputView extends QuestionInputView {
  BoolNumberInputView(
    QuestionInput questionInput,
    { void Function(Map<String, String>)? onChange, Key? key }
  ) : super(questionInput, onChange: onChange, key: key);

  @override
  _BoolNumberInputViewState createState() => _BoolNumberInputViewState();
}


class _BoolNumberInputViewState extends State<BoolNumberInputView> {
  @override
  Widget build(BuildContext context) {
    return Text('Dummy');
  }
}