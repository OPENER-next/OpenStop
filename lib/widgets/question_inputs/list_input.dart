import 'package:flutter/material.dart';
import '/widgets/question_inputs/question_input_view.dart';
import '/models/question_input.dart';

class ListInput extends QuestionInputView {
  ListInput(QuestionInput questionInput,
      {void Function(Map<String, String>)? onChange, Key? key})
      : super(questionInput, onChange: onChange, key: key);

  @override
  _ListInputState createState() => _ListInputState();
}

class _ListInputState extends State<ListInput> {
  String? _selectedKey;

  void _toogleExpand(String entry) {
    setState(() {
      if (_selectedKey == entry) {
        _selectedKey = null;
      } else {
        _selectedKey = entry;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.questionInput.values.entries.map<Widget>((entry) {
        return ListItemBuilder(
          entry: entry,
          onTap: () => _toogleExpand(entry.key),
          active: _selectedKey == entry.key,
        );
      }).toList(),
    );
  }
}

class ListItemBuilder extends StatefulWidget {
  final MapEntry<String, QuestionInputValue> entry;
  final bool active;
  final VoidCallback onTap;

  ListItemBuilder(
      {Key? key,
      required this.entry,
      required this.active,
      required this.onTap})
      : super(key: key);

  @override
  _ListItemBuilderState createState() => _ListItemBuilderState();
}

class _ListItemBuilderState extends State<ListItemBuilder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    prepareAnimations();
  }

  void prepareAnimations() {
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
        reverseDuration: const Duration(milliseconds: 500));
    _animation = CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutExpo,
        reverseCurve: Curves.ease);
  }

  @override
  void didUpdateWidget(covariant ListItemBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.0),
      child: OutlinedButton(
        style: _toggleStyle(widget.active),
        onPressed: widget.onTap,
        child: Row(
          children: [
            Flexible(
              flex: 3,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      widget.entry.value.name ?? 'Unknown label',
                      textAlign: TextAlign.left,
                    ),
                  ),
                  if (widget.entry.value.description != null)
                    SizeTransition(
                      axisAlignment: -1,
                      sizeFactor: _animation,
                      child: FadeTransition(
                        opacity: _animation,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0, right: 8.0, bottom: 8.0),
                          child: Text(
                            widget.entry.value.description ?? 'No Description',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    )
                ],
              ),
            ),
            if (widget.entry.value.image != null)
              Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(4.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(topRight: Radius.circular(8.0), bottomRight: Radius.circular(8.0)),
                      child: Image.asset(
                        'assets/placeholder_image.png',
                        fit: BoxFit.cover,
                        height: 90,
                      ),
                    ),
                  )
              )
          ],
        ),
      ),
    );
  }

  ButtonStyle? _toggleStyle(isSelected) {
    return isSelected
        ? OutlinedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            primary: Theme.of(context).colorScheme.onPrimary)
        : null;
  }
}
