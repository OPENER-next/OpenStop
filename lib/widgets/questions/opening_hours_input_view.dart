import 'package:flutter/material.dart';
import '/widgets/questions/question_input_view.dart';
import '/models/question_input.dart';


class OpeningHoursInputView extends QuestionInputView {
  OpeningHoursInputView(
    QuestionInput questionInput,
    { void Function(Map<String, String>)? onChange, Key? key }
  ) : super(questionInput, onChange: onChange, key: key);

  @override
  _OpeningHoursInputViewState createState() => _OpeningHoursInputViewState();
}


class _OpeningHoursInputViewState extends State<OpeningHoursInputView> {
  @override
  Widget build(BuildContext context) {
    return Text('Dummy');
  }
}