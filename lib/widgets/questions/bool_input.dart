import 'package:flutter/material.dart';
import '/models/question_input.dart';
import '/widgets/questions/question_input_view.dart';


class BoolInput extends QuestionInputView {
  BoolInput(
    QuestionInput questionInput,
    { void Function(Map<String, String>)? onChange, Key? key }
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
                _selectedBool = true;
              });
            }
          )
        ),
        Spacer(
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
                _selectedBool = false;
              });
            }
          )
        )
      ]
    );
  }


  ButtonStyle? _toggleStyle(isSelected) {
    return isSelected ? OutlinedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary) : null;
  }
}