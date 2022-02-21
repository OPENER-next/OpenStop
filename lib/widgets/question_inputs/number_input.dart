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

  late int? _minValue;
  late int? _maxValue;

  @override
  void initState() {
    super.initState();
    _updateMinMax();
  }


  @override
  void didUpdateWidget(covariant NumberInput oldWidget) {
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
            if (_maxValue != null && _minValue != null) {
              return 'Wert muss zwischen $_minValue und $_maxValue liegen';
            }
            else if (_maxValue != null) {
              return 'Wert darf höchstens $_maxValue sein';
            }
            else {
              return 'Wert muss mindestens $_minValue sein';
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
        FilteringTextInputFormatter.allow(_buildRegex())
      ],
    );
  }


  void _updateMinMax() {
    _minValue = widget.questionInput.min;
    _maxValue = widget.questionInput.max;
  }


  bool _isValidRange(double value) {
    if (_minValue != null && value < _minValue!) {
      return false;
    }
    if (_maxValue != null && _maxValue! < value) {
      return false;
    }
    return true;
  }


  RegExp _buildRegex() {
    var regexString = '^\\d+';
    if (widget.questionInput.decimals != null && widget.questionInput.decimals! > 0) {
      regexString += '[\\,.]?\\d{0,${widget.questionInput.decimals}}';
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
