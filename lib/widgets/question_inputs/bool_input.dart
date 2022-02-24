import 'package:flutter/material.dart';
import '/models/answer.dart';
import '/models/question_input.dart';
import '/widgets/question_inputs/question_input_view.dart';


class BoolInput extends QuestionInputView {
  const BoolInput(
    QuestionInput questionInput,
    { void Function(Answer?)? onChange, Key? key }
  ) : super(questionInput, onChange: onChange, key: key);

  @override
  _BoolInputState createState() => _BoolInputState();
}


class _BoolInputState extends State<BoolInput> {
  bool? _selectedBool;

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
    final answer = _selectedBool != null
      ? BoolAnswer(
        questionValues: widget.questionInput.values,
        value: _selectedBool!
      )
      : null;

    widget.onChange?.call(answer);
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
