import 'package:flutter/material.dart';
import '/widgets/hero_viewer.dart';
import '/models/answer.dart';
import 'question_input_widget.dart';
import '/models/question_input.dart';

class ListInput extends QuestionInputWidget<ListAnswer> {
  const ListInput({
    required QuestionInput definition,
    required AnswerController<ListAnswer> controller,
    Key? key
  }) : super(definition: definition, controller: controller, key: key);


  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 8.0,
      children: definition.values.entries.map<Widget>((entry) {
        return ListInputItem(
          item: entry.value,
          onTap: () {
            _handleChange(entry.key);
          },
          active: entry.key == controller.answer?.value,
        );
      }).toList(),
    );
  }

  void _handleChange(String selectedKey) {
    controller.answer = selectedKey != controller.answer?.value
      ? ListAnswer(
        questionValues: definition.values,
        value: selectedKey
      )
      : null;
  }
}


class ListInputItem extends StatefulWidget {
  final QuestionInputValue item;
  final bool active;
  final VoidCallback onTap;

  const ListInputItem({
    required this.item,
    required this.onTap,
    this.active = false,
    Key? key,
  }) : super(key: key);

  @override
  State<ListInputItem> createState() => _ListInputItemState();
}

class _ListInputItemState extends State<ListInputItem> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final CurvedAnimation _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      reverseDuration: const Duration(milliseconds: 500)
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutExpo,
      reverseCurve: Curves.ease
    );
  }

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
      clipBehavior: Clip.antiAlias,
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
                  padding:
                      const EdgeInsets.only(left: 16.0, top: 8.0, right: 8.0, bottom: 8.0),
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
                          style: const TextStyle(
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
              // HeroViewer cannot be wrapped around since the returned error widget
              // represents a different widget wherefore the hero transition would fail.
              child: Image.asset(
                widget.item.image!,
                fit: BoxFit.cover,
                height: 90,
                frameBuilder: (context, child, _, __) {
                  return HeroViewer(
                    child: child
                  );
                },
                errorBuilder: (context, _, __) {
                  // do not add a hero viewer to the error widget since enlarging this makes no sense
                  return Image.asset(
                    'assets/images/placeholder_image.png',
                    fit: BoxFit.cover,
                    height: 90,
                  );
                },
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
            foregroundColor: Theme.of(context).colorScheme.onPrimary)
        : null;
  }
}
