import 'package:flutter/material.dart';
import '/widgets/question_inputs/question_input_view.dart';
import '/models/question_input.dart';


class StringInput extends QuestionInputView {
  StringInput(
    QuestionInput questionInput,
    { void Function(Map<String, String>)? onChange, Key? key }
  ) : super(questionInput, onChange: onChange, key: key);

  @override
  _StringInputState createState() => _StringInputState();
}


class _StringInputState extends State<StringInput> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder()
      ),
    );
  }
}