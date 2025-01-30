
import 'package:flutter/material.dart';

class QuestionProgressBar extends ImplicitlyAnimatedWidget {
  final double value;

  final double minHeight;

  final Color? color;

  final Color backgroundColor;

  const QuestionProgressBar({
    super.key,
    this.value = 0,
    this.minHeight = 1,
    this.color,
    this.backgroundColor = Colors.transparent,
    super.duration = const Duration(milliseconds: 300),
    super.curve = Curves.ease,
  });


  @override
  AnimatedWidgetBaseState<QuestionProgressBar> createState() => _QuestionProgressBarState();
}

class _QuestionProgressBarState extends AnimatedWidgetBaseState<QuestionProgressBar> {
  Tween<double>? _valueTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _valueTween = visitor(
      _valueTween,
      widget.value,
      (value) => Tween<double>(begin: value)
    ) as Tween<double>?;
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.minHeight,
      child: ColoredBox(
        color: widget.backgroundColor,
        child: Row(
          children: [
            Expanded(
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                heightFactor: 1,
                widthFactor: _valueTween?.evaluate(animation),
                child: ColoredBox(
                  color: widget.color ?? Theme.of(context).colorScheme.primary
                ),
              )
            ),
            Expanded(
              child: FractionallySizedBox(
                alignment: Alignment.centerRight,
                heightFactor: 1,
                widthFactor: _valueTween?.evaluate(animation),
                child: ColoredBox(
                  color: widget.color ?? Theme.of(context).colorScheme.primary
                ),
              )
            )
          ],
        )
      )
    );
  }
}
