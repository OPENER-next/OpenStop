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
  final _textController = TextEditingController();

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
              onPressed: _handleChange,
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


  bool _isValidRange(double value) {
    final questionInputValue = widget.definition.values.values.first;
    if (questionInputValue.min != null && value < questionInputValue.min!) {
      return false;
    }
    if (questionInputValue.max != null && questionInputValue.max! < value) {
      return false;
    }
    return true;
  }

  void _handleChange([String value = '']) {
    final tmpValue = value.replaceAll(',', '.');
    NumberAnswer? answer;

    if (double.tryParse(tmpValue) != null) {
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
    var allowRegexString = '';

    if (negativeAllowed) {
      allowRegexString += '-?';
    }
    allowRegexString += '([1-9]\\d*|0?)';
    if (decimals == null) {
      allowRegexString += '([,.]\\d*)?';
    }
    else if (decimals! > 0) {
      allowRegexString += '([,.]\\d{0,$decimals})?';
    }
    final allowRegex = RegExp(allowRegexString);

    if (allowRegex.stringMatch(newValue.text) == newValue.text) {
      return newValue;
    }
    return oldValue;
  }
}
