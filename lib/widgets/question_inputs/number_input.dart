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
  late final minValue = widget.questionInput.min?.toDouble() ?? double.negativeInfinity;
  late final maxValue = widget.questionInput.max?.toDouble() ?? double.infinity;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _controller,
        builder: (context, TextEditingValue value, __) {
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
                final value = double.parse(text);
                if (!_isValid(value)) {
                  return 'Wert muss zwischen $minValue und $maxValue liegen';
                }
              }
              return null;
            },
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: false,
            ),
            inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d+(\,)?\d{0,''${widget.questionInput.decimals}}'))
            ],
          );
        }
        );
  }


  bool _isValid(double value) => value >= minValue && value <= maxValue;


  void _handleClear() {
    _controller.clear();
    _handleChange();
  }


  void _handleChange([String value = '']) {
    value = value.replaceAll(',', '.');
    Answer? answer;

    if (value.isNotEmpty) {
      final numberValue = double.parse(value);
      if (_isValid(numberValue)) {
        answer = NumberAnswer(
          questionValues: widget.questionInput.values,
          answer: numberValue
        );
      }
    }

    widget.onChange?.call(answer);
  }
}
