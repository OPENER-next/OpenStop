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

  late double _minValue;
  late double _maxValue;

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
            if (_maxValue != double.infinity && _minValue != double.negativeInfinity) {
              return 'Wert muss zwischen $_minValue und $_maxValue liegen';
            }
            else if (_maxValue != double.infinity) {
              return 'Wert muss gleich oder kleiner sein als $_maxValue';
            }
            else {
              return 'Wert muss gleich oder größer sein als $_minValue';
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
        FilteringTextInputFormatter.allow(RegExp('^\\d+((\\,)?\\d{0,${widget.questionInput.decimals}}){${widget.questionInput.decimals == 0 ? 0 : 1}}'))
      ],
    );
  }


  void _updateMinMax() {
    _minValue = widget.questionInput.min?.toDouble() ?? double.negativeInfinity;
    _maxValue = widget.questionInput.max?.toDouble() ?? double.infinity;
  }


  bool _isValidRange(double value) => value >= _minValue && value <= _maxValue;


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
