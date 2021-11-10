import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/widgets/question_inputs/question_input_view.dart';
import '/models/question_input.dart';


class NumberInput extends QuestionInputView {
  NumberInput(
    QuestionInput questionInput,
    { void Function(Map<String, String>)? onChange, Key? key }
  ) : super(questionInput, onChange: onChange, key: key) ;

  @override
  _NumberInputState createState() => _NumberInputState();
}


class _NumberInputState extends State<NumberInput> {
  late final allowsDecimals;

  @override
  void initState() {
    super.initState();

    allowsDecimals = widget.questionInput.decimals != null ? (widget.questionInput.decimals! > 0) : true;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        suffixText: widget.questionInput.unit,
      ),
      keyboardType: TextInputType.numberWithOptions(
        decimal: allowsDecimals,
        signed: false,
      ),
      inputFormatters: <TextInputFormatter>[
        allowsDecimals ?
          FilteringTextInputFormatter.allow(RegExp(r'([0-9]*\.)?[0-9]*')) :
          FilteringTextInputFormatter.digitsOnly,
        LimitRangeTextInputFormatter(
          widget.questionInput.min?.toDouble() ?? double.negativeInfinity,
          widget.questionInput.max?.toDouble() ?? double.infinity
        )
      ],
    );
  }
}


class LimitRangeTextInputFormatter extends TextInputFormatter {
  LimitRangeTextInputFormatter(this.min, this.max) : assert(min < max);

  final double min;
  final double max;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final value = double.parse(newValue.text);
    if (value < min) {
      return TextEditingValue(text: min.toString());
    } else if (value > max) {
      return TextEditingValue(text: max.toString());
    }
    return newValue;
  }
}