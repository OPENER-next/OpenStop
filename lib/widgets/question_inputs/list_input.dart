import 'package:flutter/material.dart';
import '/models/answer.dart';
import '/widgets/question_inputs/question_input_view.dart';
import '/models/question_input.dart';

class ListInput extends QuestionInputView {
  ListInput(QuestionInput questionInput,
      { void Function(Answer?)? onChange, Key? key })
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
    return Wrap(
      runSpacing: 8.0,
      children: widget.questionInput.values.entries.map<Widget>((entry) {
        return ListInputItem(
          item: entry.value,
          onTap: () => _toogleExpand(entry.key),
          active: _selectedKey == entry.key,
        );
      }).toList(),
    );
  }
}

class ListInputItem extends StatefulWidget {
  final QuestionInputValue item;
  final bool active;
  final VoidCallback onTap;

  ListInputItem(
      {Key? key,
        required this.item,
        required this.onTap,
        this.active = false})
      : super(key: key);

  @override
  _ListInputItemState createState() => _ListInputItemState();
}

class _ListInputItemState extends State<ListInputItem>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      reverseDuration: const Duration(milliseconds: 500)
  );

  late final _animation = CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutExpo,
        reverseCurve: Curves.ease
  );

  @override
  void didUpdateWidget(covariant ListInputItem oldWidget) {
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
    return OutlinedButton(
      style: _toggleStyle(widget.active),
      onPressed: widget.onTap,
      child: Row(
        children: [
          Flexible(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                  child: Text(
                    widget.item.name ?? 'Unknown label',
                    textAlign: TextAlign.left,
                  ),
                ),
                if (widget.item.description != null)
                  SizeTransition(
                    axisAlignment: -1,
                    sizeFactor: _animation,
                    child: FadeTransition(
                      opacity: _animation,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 8.0, bottom: 8.0),
                        child: Text(
                          widget.item.description ?? 'No Description',
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
          if (widget.item.image != null)
            Expanded(
                flex: 2,
                child: Padding(
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
