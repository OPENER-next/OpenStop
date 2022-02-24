import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/models/answer.dart';
import '/widgets/question_inputs/question_input_view.dart';
import '/models/question_input.dart';

class NumberInput extends QuestionInputView {
  const NumberInput(
    QuestionInput questionInput,
    { void Function(Answer?)? onChange, Key? key }
  ) : super(questionInput, onChange: onChange, key: key) ;

  @override
  _NumberInputState createState() => _NumberInputState();
}


class _NumberInputState extends State<NumberInput> {
  final _controller = TextEditingController();


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
              return 'Wert muss zwischen $widget.questionInput.min und $widget.questionInput.max liegen';
            }
            else if (questionInputValue.max != null) {
              return 'Wert darf höchstens $widget.questionInput.max sein';
            }
            else {
              return 'Wert muss mindestens $widget.questionInput.min sein';
            }
          }
        }
        return null;
      },
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: false,
      ),
      inputFormatters: <TextInputFormatter>[
        /// First conditionally deny comma or point, then check allowed decimal places. Doesn't work vice versa.
        FilteringTextInputFormatter.deny(_buildDenyRegex()),
        FilteringTextInputFormatter.allow(_buildAllowRegex())
      ],
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


  RegExp _buildDenyRegex() {
    final questionInputValue = widget.questionInput.values.values.first;
    if (questionInputValue.decimals != null && questionInputValue.decimals! == 0) {
      return RegExp('');
    }
    else {
      return RegExp('[,.]{1}');
    }
  }


  RegExp _buildAllowRegex() {
    final questionInputValue = widget.questionInput.values.values.first;
    var regexString = '^\\d+';
    if (questionInputValue.decimals != null && questionInputValue.decimals! > 0) {
      regexString += '[,.]?\\d{0,${questionInputValue.decimals}}';
    }
    return RegExp(regexString);
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
        answer: numberValue
      );
    }

    widget.onChange?.call(answer);
  }
}
