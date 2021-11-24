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
  final _controller = TextEditingController();
  late FocusNode _focusNode;
  void _clearTextfield (){
    _controller.clear();
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(()  {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: _focusNode,
      controller: _controller,
      decoration: InputDecoration(
        hintText: "Hier eintragen...",
        suffixIcon: IconButton(
          onPressed: _focusNode.hasFocus ? () => _clearTextfield() : null,
          disabledColor: Colors.transparent,
          color: Colors.black54,
          icon: Icon(Icons.clear_rounded),
        )
      ),
    );
  }
}