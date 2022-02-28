import 'package:flutter/material.dart';
import '/models/answer.dart';
import 'question_input_widget.dart';
import '/models/question_input.dart';


class StringInput extends QuestionInputWidget {
  const StringInput(
    QuestionInput questionInput,
    { AnswerController? controller, Key? key }
  ) : super(questionInput, controller: controller, key: key);

  @override
  _StringInputState createState() => _StringInputState();
}


class _StringInputState extends QuestionInputWidgetState {
  final _controller = TextEditingController();

  late int _minValue;
  late int _maxValue;

  @override
  void initState() {
    super.initState();
    _updateMinMax();
    _controller.text = widget.controller?.answer?.value ?? '';
  }


  @override
  void didUpdateWidget(covariant StringInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateMinMax();
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questionInputValue = widget.questionInput.values.values.first;

    return TextFormField(
      onChanged: _handleChange,
      controller: _controller,
      maxLength: _maxValue,
      decoration: InputDecoration(
        hintText: questionInputValue.name ?? 'Hier eintragen...',
        counter: const Offstage(),
        suffixIcon: IconButton(
          onPressed: _handleClear,
          color: Colors.black87,
          icon: const Icon(Icons.clear_rounded),
        )
      ),
      autovalidateMode: AutovalidateMode.always,
      validator: (text) {
        if (text != null && text.isNotEmpty && text.length < _minValue ) {
          return 'Eingabe zu kurz';
        }
        return null;
      },
    );
  }


  void _updateMinMax() {
    final questionInputValue = widget.questionInput.values.values.first;
    _minValue = questionInputValue.min ?? 0;
    _maxValue = questionInputValue.max ?? 255;
  }


  bool _isValidLength(String value) => value.length >= _minValue && value.length <= _maxValue;


  void _handleClear() {
    _controller.clear();
    _handleChange();
  }


  void _handleChange([String value = '']) {
    Answer? answer;

    if (value.isNotEmpty && _isValidLength(value)) {
      answer = StringAnswer(
        questionValues: widget.questionInput.values,
        value: value
      );
    }

    widget.controller?.answer = answer;
  }
}
