import 'package:flutter/material.dart';

import '/models/answer.dart';
import '/models/question_catalog/answer_definition.dart';
import '/widgets/hero_viewer.dart';
import 'question_input_widget.dart';

class ListInput extends QuestionInputWidget<ListAnswerDefinition, ListAnswer> {
  const ListInput({
    required super.definition,
    required super.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 8.0,
      children: List.generate(definition.input.length, (index) {
        final item = definition.input[index];
        return ListInputItem(
          active: index == controller.answer?.value,
          label: item.name,
          description: item.description,
          imagePath: item.image,
          onTap: () => _handleChange(index),
        );
      }, growable: false),
    );
  }

  void _handleChange(int selectedIndex) {
    controller.answer = selectedIndex != controller.answer?.value
      ? ListAnswer(
        definition: definition,
        value: selectedIndex
      )
      : null;
  }
}


class ListInputItem extends StatefulWidget {
  final String label;
  final String? description;
  final String? imagePath;
  final double imagePadding;
  final bool active;
  final VoidCallback onTap;

  const ListInputItem({
    required this.label,
    required this.onTap,
    this.active = false,
    this.description,
    this.imagePath,
    this.imagePadding = 4.0,
    super.key,
  });

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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonShape = theme.outlinedButtonTheme.style?.shape?.resolve({});
    final innerBorderRadius = buttonShape is RoundedRectangleBorder
        ? buttonShape.borderRadius.subtract(BorderRadius.circular(widget.imagePadding))
        : null;
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
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    top: 8.0,
                    right: 8.0,
                    bottom: 8.0,
                  ),
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.left,
                  ),
                ),
                if (widget.description != null)
                  SizeTransition(
                    axisAlignment: -1,
                    sizeFactor: _animation,
                    child: FadeTransition(
                      opacity: _animation,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 16.0,
                          right: 8.0,
                          bottom: 8.0,
                        ),
                        child: Text(
                          widget.description!,
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (widget.imagePath != null)
            Expanded(
              flex: 2,
              // HeroViewer cannot be wrapped around since the returned error widget
              // represents a different widget wherefore the hero transition would fail.
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, widget.imagePadding, widget.imagePadding, widget.imagePadding),
                child: ClipRRect(
                  borderRadius: innerBorderRadius,
                  child: Image.asset(
                    widget.imagePath!,
                    fit: BoxFit.cover,
                    // Static background color for better visibility of illustrations
                    // with transparency, especially in dark mode
                    colorBlendMode: BlendMode.dstOver,
                    color: Colors.grey.shade100,
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
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  ButtonStyle? _toggleStyle(isSelected) {
    return isSelected
      ? OutlinedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        )
      : null;
  }
}
