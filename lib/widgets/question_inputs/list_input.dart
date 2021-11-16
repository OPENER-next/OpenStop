import 'package:flutter/material.dart';
import '/widgets/question_inputs/question_input_view.dart';
import '/models/question_input.dart';

// Split type in List and Grid view?
// Maybe use: https://api.flutter.dev/flutter/material/ExpansionPanel-class.html for lists to show more details on demand

class ListInput extends QuestionInputView {
  ListInput(QuestionInput questionInput,
      {void Function(Map<String, String>)? onChange, Key? key})
      : super(questionInput, onChange: onChange, key: key);

  @override
  _ListInputState createState() => _ListInputState();
}

class _ListInputState extends State<ListInput> {
  String? _selectedKey;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      primary: true,
      shrinkWrap: true,
      children: widget.questionInput.values.entries.map<Widget>((entry) {
        return Container(
            margin: EdgeInsets.only(bottom: 8.0),
            width: double.infinity,
            child: OutlinedButton(
                child: Row(
                  children: [
                    Flexible(
                      flex: 3,
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                entry.value.name ?? 'Unknown label',
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          if (_selectedKey == entry.key &&
                              entry.value.description != null)
                            Container(
                              padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                              child: Text(
                                entry.value.description ?? 'No Description',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                    if (entry.value.image != null)
                      Flexible(
                          flex: 2,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(4.0),
                            child: Image.asset(
                              'assets/symbols/bus_stop.png',
                              fit: BoxFit.cover,
                              height: 100,
                            ),
                          ))
                  ],
                ),
                style: _toggleStyle(_selectedKey == entry.key),
                onPressed: () {
                  setState(() {
                    if (_selectedKey == entry.key) {
                      _selectedKey = null;
                    } else
                      _selectedKey = entry.key;
                  });
                }));
      }).toList(),
    );
  }

  ButtonStyle? _toggleStyle(isSelected) {
    return isSelected
        ? OutlinedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            primary: Theme.of(context).colorScheme.onPrimary,
            padding: EdgeInsets.all(0.0))
        : OutlinedButton.styleFrom(padding: EdgeInsets.all(0.0));
  }
}
