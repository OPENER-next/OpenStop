import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/models/answer.dart';
import 'question_input_widget.dart';
import '/models/question_input.dart';

class NumberInput extends QuestionInputWidget{
  const NumberInput(
    QuestionInput questionInput,
    { AnswerController? controller, Key? key }
  ) : super(questionInput, controller: controller, key: key);

  @override
  _NumberInputState createState() => _NumberInputState();
}


class _NumberInputState extends QuestionInputWidgetState {
  final _controller = TextEditingController();


  @override
  void initState() {
    super.initState();
    _controller.text = widget.controller?.answer?.value.toString() ?? '';
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
      decoration: InputDecoration(
        hintText: questionInputValue.name ?? 'Hier eintragen...',
        suffixIcon: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (questionInputValue.unit != null) Text(
              questionInputValue.unit!,
              style: Theme.of(context).textTheme.subtitle1
            ),
            IconButton(
              onPressed: _handleClear,
              color: Colors.black87,
              icon: const Icon(Icons.clear_rounded),
            )
          ]
        )
      ),
      autovalidateMode: AutovalidateMode.always,
      validator: (text) {
        if (text != null && text.isNotEmpty) {
          text = text.replaceAll(',', '.');
          final value = double.tryParse(text);
          if (value == null) {
            return 'Ungültige Zahl';
          }
          else if (!_isValidRange(value)) {
            if (questionInputValue.max != null && questionInputValue.min != null) {
              return 'Wert muss zwischen ${questionInputValue.min} und ${questionInputValue.max} liegen';
            }
            else if (questionInputValue.max != null) {
              return 'Wert darf höchstens ${questionInputValue.max} sein';
            }
            else {
              return 'Wert muss mindestens ${questionInputValue.min} sein';
            }
          }
        }
        return null;
      },
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: false,
      ),
      inputFormatters: _buildInputFormatters()
    );
  }


  bool _isValidRange(double value) {
    final questionInputValue = widget.questionInput.values.values.first;
    if (questionInputValue.min != null && value < questionInputValue.min!) {
      return false;
    }
    if (questionInputValue.max != null && questionInputValue.max! < value) {
      return false;
    }
    return true;
  }


  List<TextInputFormatter> _buildInputFormatters() {
    final questionInputValue = widget.questionInput.values.values.first;

    final decimalsAllowed = questionInputValue.decimals != null && questionInputValue.decimals! > 0;

    var allowRegexString = '^\\d+';
    if (decimalsAllowed) {
      allowRegexString += '[,.]?\\d{0,${questionInputValue.decimals}}';
    }

    return [
      /// First conditionally deny comma or point, then check allowed decimal places. Doesn't work vice versa.
      if (!decimalsAllowed) FilteringTextInputFormatter.deny( RegExp('[,.]{1}') ),
      FilteringTextInputFormatter.allow( RegExp(allowRegexString) )
    ];
  }


  void _handleClear() {
    _controller.clear();
    _handleChange();
  }


  void _handleChange([String value = '']) {
    value = value.replaceAll(',', '.');
    Answer? answer;

    final numberValue = double.tryParse(value);
    if (numberValue != null && _isValidRange(numberValue)) {
      answer = NumberAnswer(
        questionValues: widget.questionInput.values,
        value: numberValue
      );
    }

    widget.controller?.answer = answer;
  }
}
