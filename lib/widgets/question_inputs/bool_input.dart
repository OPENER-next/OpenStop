import 'package:flutter/material.dart';
import '/models/answer.dart';
import '/models/question_input.dart';
import 'question_input_widget.dart';


class BoolInput extends QuestionInputWidget {
  const BoolInput(
    QuestionInput questionInput,
    { AnswerController? controller, Key? key }
  ) : super(questionInput, controller: controller, key: key);

  @override
  _BoolInputState createState() => _BoolInputState();
}


class _BoolInputState extends QuestionInputWidgetState {
  bool? _selectedBool;

  @override
  void initState() {
    super.initState();
    _selectedBool = widget.controller?.answer?.value;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Flexible(
          fit: FlexFit.tight,
          flex: 3,
          child: OutlinedButton(
            child: Text(
              widget.questionInput.values['true']?.name ?? 'Ja'
            ),
            style: _toggleStyle(_selectedBool == true),
            onPressed: () {
              setState(() {
                _selectedBool = _selectedBool != true ? true : null;
                _handleChange();
              });
            }
          )
        ),
        const Spacer(
          flex: 1,
        ),
        Flexible(
          fit: FlexFit.tight,
          flex: 3,
          child: OutlinedButton(
            child: Text(
              widget.questionInput.values['false']?.name ?? 'Nein'
            ),
            style: _toggleStyle(_selectedBool == false),
            onPressed: () {
              setState(() {
                _selectedBool = _selectedBool != false ? false : null;
                _handleChange();
              });
            }
          )
        )
      ]
    );
  }


  void _handleChange() {
    widget.controller?.answer = _selectedBool != null
      ? BoolAnswer(
        questionValues: widget.questionInput.values,
        value: _selectedBool!
      )
      : null;
  }


  ButtonStyle? _toggleStyle(bool isSelected) {
    return isSelected
      ? OutlinedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          primary: Theme.of(context).colorScheme.onPrimary,
        )
      : null;
  }
}
