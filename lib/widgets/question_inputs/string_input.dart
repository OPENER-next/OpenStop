import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/models/answer.dart';
import '/models/question_catalog/answer_definition.dart';
import 'question_input_widget.dart';


class StringInput extends QuestionInputWidget<StringAnswerDefinition, StringAnswer> {
  const StringInput({
    required super.definition,
    required super.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return _StringInputDelegate(definition, controller);
  }
}


// This StatefulWidget is required because we are dealing with two controllers which need
// to be linked together. This can only be achieved in a StatefulWidget.
// For example when the AnswerController gets reset/changed from the outside it needs to
// propagate the changes to the TextEditingController

class _StringInputDelegate extends StatefulWidget {
  final StringAnswerDefinition definition;
  final AnswerController<StringAnswer> controller;

  const _StringInputDelegate(this.definition, this.controller);

  @override
  State<_StringInputDelegate> createState() => _StringInputDelegateState();
}

class _StringInputDelegateState extends State<_StringInputDelegate> {
  late final _textController = TextEditingController(
    text: widget.controller.answer?.value
  );

  @override
  void didUpdateWidget(covariant _StringInputDelegate oldWidget) {
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
    final appLocale = AppLocalizations.of(context)!;

    return TextFormField(
      controller: _textController,
      onChanged: _handleChange,
      textAlignVertical: TextAlignVertical.center,
      maxLength: input.max,
      decoration: InputDecoration(
        hintText: input.placeholder ?? appLocale.stringInputPlaceholder,
        counter: const Offstage(),
        suffixIcon: IconButton(
          onPressed: _handleChange,
          icon: Icon(Icons.clear_rounded, semanticLabel: appLocale.semanticsClearFieldLabel,),
          highlightColor: Colors.transparent,
        ),
      ),
      autovalidateMode: AutovalidateMode.always,
      validator: (text) {
        if (text != null && text.isNotEmpty && text.length <  input.min ) {
          return appLocale.stringInputValidationErrorMin;
        }
        return null;
      },
    );
  }

  void _handleChange([String value = '']) {
    widget.controller.answer = value.isNotEmpty
      ? StringAnswer(
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
