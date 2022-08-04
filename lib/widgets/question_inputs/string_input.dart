import 'package:flutter/material.dart';
import '/models/answer.dart';
import 'question_input_widget.dart';
import '/models/question_input.dart';


class StringInput extends QuestionInputWidget<StringAnswer> {
  const StringInput({
    required QuestionInput definition,
    required AnswerController<StringAnswer> controller,
    Key? key
  }) : super(definition: definition, controller: controller, key: key);

  @override
  Widget build(BuildContext context) {
    return _StringInputDelegate(definition, controller, key: ValueKey(definition));
  }
}


// This StatefulWidget is required because we are dealing with two controllers which need
// to be linked together. This can only be achieved in a StatefulWidget.
// For example when the AnswerController gets reset/changed from the outside it needs to
// propagate the changes to the TextEditingController

class _StringInputDelegate extends StatefulWidget {
    final QuestionInput definition;
    final AnswerController<StringAnswer> controller;

  const _StringInputDelegate(this.definition, this.controller, {
    Key? key
  }) : super(key: key);

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

    return TextFormField(
      controller: _textController,
      onChanged: _handleChange,
      textAlignVertical: TextAlignVertical.center,
      maxLength: _maxValue,
      decoration: InputDecoration(
        hintText: questionInputValue.name ?? 'Hier eintragen...',
        counter: const Offstage(),
        suffixIcon: IconButton(
          onPressed: _handleChange,
          icon: const Icon(Icons.clear_rounded),
        )
      ),
      autovalidateMode: AutovalidateMode.always,
      validator: (text) {
        if (text != null && text.isNotEmpty && text.length < _minValue ) {
          return 'Eingabe zu kurz';
        }
        return null;
      },
    );
  }

  int get _minValue => widget.definition.values.values.first.min ?? 0;

  int get _maxValue => widget.definition.values.values.first.max ?? 255;


  void _handleChange([String value = '']) {
    StringAnswer? answer;

    if (value.isNotEmpty) {
      answer = StringAnswer(
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
