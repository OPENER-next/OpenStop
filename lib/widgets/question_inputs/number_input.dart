import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/models/answer.dart';
import 'question_input_widget.dart';
import '/models/question_input.dart';

class NumberInput extends QuestionInputWidget<NumberAnswer> {
  const NumberInput({
    required QuestionInput definition,
    required AnswerController<NumberAnswer> controller,
    Key? key
  }) : super(definition: definition, controller: controller, key: key);


  @override
  Widget build(BuildContext context) {
    return _NumberInputDelegate(definition, controller, key: ValueKey(definition));
  }
}


// This StatefulWidget is required because we are dealing with two controllers which need
// to be linked together. This can only be achieved in a StatefulWidget.
// For example when the AnswerController gets reset/changed from the outside it needs to
// propagate the changes to the TextEditingController

class _NumberInputDelegate extends StatefulWidget {
    final QuestionInput definition;
    final AnswerController<NumberAnswer> controller;

  const _NumberInputDelegate(this.definition, this.controller, {
    Key? key
  }) : super(key: key);

  @override
  State<_NumberInputDelegate> createState() => _NumberInputDelegateState();
}

class _NumberInputDelegateState extends State<_NumberInputDelegate> {
  late final _textController = TextEditingController(
    text: widget.controller.answer?.value
  );

  @override
  void didUpdateWidget(covariant _NumberInputDelegate oldWidget) {
    super.didUpdateWidget(oldWidget);
    // since the outer widget will always rebuild this widget on controller notifications
    // we don't actually need to listen to the controller
    final newValue = widget.controller.answer?.value ?? '';
    if (_textController.text != newValue) {
      _textController.value = TextEditingValue(
        text: newValue,
        // required, otherwise the input loses focus when clearing it
        // even though the cursor is still displayed in the input and pressing a special character
        // like a dot (.) will refocus the input field for whatever reason
        selection: TextSelection.collapsed(offset: newValue.length)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionInputValue = widget.definition.values.values.first;

    final decimalsAllowed = questionInputValue.decimals == null || questionInputValue.decimals! > 0;
    final negativeAllowed = questionInputValue.min == null || questionInputValue.min! < 0;

    return TextFormField(
      controller: _textController,
      onChanged: _handleChange,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        hintText: questionInputValue.name ?? 'Hier eintragen...',
        suffixText: questionInputValue.unit,
        suffixIcon: IconButton(
          onPressed: _handleChange,
          icon: const Icon(Icons.clear_rounded),
        ),
        errorMaxLines: 2,
      ),
      autovalidateMode: AutovalidateMode.always,
      validator: (text) {
        if (text != null && text.isNotEmpty) {

          final answer = NumberAnswer(
              questionValues: widget.definition.values,
              value: text
          );

          if (!answer.isValid) {
            final number = double.tryParse( text.replaceAll(',', '.') );

            final nameString = questionInputValue.name ?? 'Wert';
            final unitString = questionInputValue.unit != null
              ? ' ${questionInputValue.unit}'
              : '';

            if (number != null) {
              if (questionInputValue.max != null && number > questionInputValue.max!) {
                return 'Zu hoch! $nameString darf ${questionInputValue.max}$unitString nicht überschreiten.';
              }
              else if (questionInputValue.min != null && number < questionInputValue.min!) {
                return 'Zu niedrig! $nameString darf ${questionInputValue.min}$unitString nicht unterschreiten.';
              }
            }
            return 'Ungültige Zahl';
          }
        }
        return null;
      },
      keyboardType: TextInputType.numberWithOptions(
        decimal: decimalsAllowed,
        signed: negativeAllowed
      ),
      inputFormatters: [
        NumberTextInputFormatter(
            decimals: questionInputValue.decimals,
            negativeAllowed: negativeAllowed
        ),
      ],
    );
  }

  void _handleChange([String value = '']) {
    NumberAnswer? answer;

    if (value.isNotEmpty) {
      answer = NumberAnswer(
        questionValues: widget.definition.values,
        value: value
      );
    }

    widget.controller.answer = answer;
  }


  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

class NumberTextInputFormatter extends TextInputFormatter {
  NumberTextInputFormatter({
    this.negativeAllowed = true,
    this.decimals,
  });

  final int? decimals;
  final bool negativeAllowed;


  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final allowRegexStringBuilder = StringBuffer(r'^');
    // match negative numbers
    if (negativeAllowed) {
      allowRegexStringBuilder.write(r'-?');
    }
    // match either a single 0, a number not starting with 0, or nothing
    allowRegexStringBuilder.write(r'(0|[1-9]\d*)?');
    // match an unlimited amount of decimal places
    if (decimals == null) {
      allowRegexStringBuilder.write(r'([,.]\d*)?');
    }
    // match a specific amount of decimal places
    else if (decimals! > 0) {
      allowRegexStringBuilder..write(r'([,.]\d{0,')..write(decimals)..write(r'})?');
    }
    allowRegexStringBuilder.write(r'$');

    final allowRegex = RegExp(allowRegexStringBuilder.toString());

    if (allowRegex.stringMatch(newValue.text) == newValue.text) {
      return newValue;
    }
    return oldValue;
  }
}
