import 'package:flutter/material.dart';
import '/widgets/questions/question_input_view.dart';
import '/models/question_input.dart';


class DurationInputView extends QuestionInputView {
  DurationInputView(
    QuestionInput questionInput,
    { void Function(Map<String, String>)? onChange, Key? key }
  ) : super(questionInput, onChange: onChange, key: key);

  @override
  _DurationInputViewState createState() => _DurationInputViewState();
}


class _DurationInputViewState extends State<DurationInputView> {
  @override
  Widget build(BuildContext context) {
    return Text('Dummy');
  }
}