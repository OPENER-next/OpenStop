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
    return TextFormField(
      onChanged: _handleChange,
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Hier eintragen...',
        suffixIcon: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.questionInput.unit,
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
            if (widget.questionInput.max != null && widget.questionInput.min != null) {
              return 'Wert muss zwischen $widget.questionInput.min und $widget.questionInput.max liegen';
            }
            else if (widget.questionInput.max != null) {
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
    if (widget.questionInput.min != null && value < widget.questionInput.min!) {
      return false;
    }
    if (widget.questionInput.max != null && widget.questionInput.max! < value) {
      return false;
    }
    return true;
  }


  RegExp _buildDenyRegex() {
    if (widget.questionInput.decimals != null && widget.questionInput.decimals! == 0) {
      return RegExp('');
    }
    else {
      return RegExp('[,.]{1}');
    }
  }


  RegExp _buildAllowRegex() {
    var regexString = '^\\d+';
    if (widget.questionInput.decimals != null && widget.questionInput.decimals! > 0) {
      regexString += '[,.]?\\d{0,${widget.questionInput.decimals}}';
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
