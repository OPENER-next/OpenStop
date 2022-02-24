import 'package:flutter/material.dart';
import '/models/answer.dart';
import '/widgets/question_inputs/question_input_view.dart';
import '/models/question_input.dart';


class StringInput extends QuestionInputView {
  const StringInput(
    QuestionInput questionInput,
    { void Function(Answer?)? onChange, Key? key }
  ) : super(questionInput, onChange: onChange, key: key);

  @override
  _StringInputState createState() => _StringInputState();
}


class _StringInputState extends State<StringInput> {
  final _controller = TextEditingController();

  late int _minValue;
  late int _maxValue;

  @override
  void initState() {
    super.initState();
    _updateMinMax();
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
    return TextFormField(
      onChanged: _handleChange,
      controller: _controller,
      maxLength: _maxValue,
      decoration: InputDecoration(
        hintText: 'Hier eintragen...',
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
        answer: value
      );
    }

    widget.onChange?.call(answer);
  }
}
