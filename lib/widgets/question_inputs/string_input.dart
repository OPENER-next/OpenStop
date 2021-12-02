import 'package:flutter/material.dart';
import '/models/answer.dart';
import '/widgets/question_inputs/question_input_view.dart';
import '/models/question_input.dart';


class StringInput extends QuestionInputView {
  StringInput(
    QuestionInput questionInput,
    { void Function(Answer?)? onChange, Key? key }
  ) : super(questionInput, onChange: onChange, key: key);

  @override
  _StringInputState createState() => _StringInputState();
}


class _StringInputState extends State<StringInput> {
  final _controller = TextEditingController();
  void _clearTextfield (){
    _controller.clear();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: "Hier eintragen...",
        suffixIcon: IconButton(
          onPressed: () => _clearTextfield(),
          color: Colors.black87,
          icon: Icon(Icons.clear_rounded),
        )
      ),
    );
  }
}