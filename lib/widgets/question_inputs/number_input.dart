// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '/models/answer.dart';
import '/models/question_catalog/answer_definition.dart';
import 'question_input_widget.dart';

class NumberInput extends QuestionInputWidget<NumberAnswerDefinition, NumberAnswer> {
  const NumberInput({
    required super.definition,
    required super.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return _NumberInputDelegate(definition, controller);
  }
}


// This StatefulWidget is required because we are dealing with two controllers which need
// to be linked together. This can only be achieved in a StatefulWidget.
// For example when the AnswerController gets reset/changed from the outside it needs to
// propagate the changes to the TextEditingController

class _NumberInputDelegate extends StatefulWidget {
  final NumberAnswerDefinition definition;
  final AnswerController<NumberAnswer> controller;

  const _NumberInputDelegate(this.definition, this.controller);

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
      final selection = _textController.selection.end > newValue.length
        // required, otherwise the input loses focus when clearing it
        // even though the cursor is still displayed in the input and pressing a special character
        // like a dot (.) will refocus the input field for whatever reason
        ? TextSelection.collapsed(offset: newValue.length)
        : null;
      _textController.value = _textController.value.copyWith(text: newValue, selection: selection);
    }
  }

  @override
  Widget build(BuildContext context) {
    final input = widget.definition.input;
    final decimalsAllowed = input.decimals == null || input.decimals! > 0;
    final negativeAllowed = input.min == null || input.min! < 0;
    final appLocale = AppLocalizations.of(context)!;

    return TextFormField(
      controller: _textController,
      onChanged: _handleChange,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        hintText: input.placeholder ?? appLocale.numberInputPlaceholder,
        suffixText: input.unit,
        suffixIcon: IconButton(
          onPressed: _handleChange,
          icon: const Icon(Icons.clear_rounded),
          highlightColor: Colors.transparent,
        ),
        errorMaxLines: 2,
      ),
      autovalidateMode: AutovalidateMode.always,
      validator: (text) {
        if (text != null && text.isNotEmpty) {
          final answer = NumberAnswer(
            definition: widget.definition,
            value: text,
          );

          if (!answer.isValid) {
            final number = double.tryParse( text.replaceAll(',', '.') );

            final nameString = input.placeholder ?? appLocale.numberInputFallbackName;
            final unitString = input.unit != null
              ? ' ${input.unit}'
              : '';

            if (number != null) {
              if (input.max != null && number > input.max!) {
                return appLocale.numberInputValidationErrorMax(nameString, input.max!, unitString);
              }
              else if (input.min != null && number < input.min!) {
                return appLocale.numberInputValidationErrorMin(nameString, input.min!, unitString);
              }
            }
            return appLocale.numberInputValidationError;
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
            decimals: input.decimals,
            negativeAllowed: negativeAllowed
        ),
      ],
    );
  }

  void _handleChange([String value = '']) {
    widget.controller.answer = value.isNotEmpty
      ? NumberAnswer(
        definition: widget.definition,
        value: value
      )
      : null;
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
