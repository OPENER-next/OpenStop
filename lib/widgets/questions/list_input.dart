import 'package:flutter/material.dart';
import '/widgets/questions/question_input_view.dart';
import '/models/question_input.dart';


// Split type in List and Grid view?
// Maybe use: https://api.flutter.dev/flutter/material/ExpansionPanel-class.html for lists to show more details on demand



class ListInput extends QuestionInputView {
  ListInput(
    QuestionInput questionInput,
    { void Function(Map<String, String>)? onChange, Key? key }
  ) : super(questionInput, onChange: onChange, key: key);

  @override
  _ListInputState createState() => _ListInputState();
}


class _ListInputState extends State<ListInput> {
  String? _selectedKey;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: EdgeInsets.zero,
      primary: false,
      shrinkWrap: true,
      crossAxisCount: 3,
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      children: widget.questionInput.values.entries.map<Widget>((entry) {
        return Stack(
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                border: _selectedKey != entry.key ? null : Border.all(
                  width: 2,
                  color: Theme.of(context).accentColor
                ),
                image: DecorationImage(
                  colorFilter: _selectedKey != entry.key ? null : ColorFilter.mode(
                    Colors.black38,
                    BlendMode.overlay
                  ),
                  fit: BoxFit.cover,
                  image: AssetImage('assets/symbols/bus_stop.png')
                )
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (_selectedKey == entry.key) {
                        _selectedKey = null;
                      }
                      else _selectedKey = entry.key;
                    });
                  }
                ),
              )
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                entry.value.name ?? 'Unknown label',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: <Shadow>[
                    Shadow(
                      blurRadius: 3.0,
                      color: Color.fromARGB(140, 0, 0, 0),
                    )
                  ]
                ),
              )
            ),
          ],
        );
      }).toList(),
    );
  }
}