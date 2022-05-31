import 'package:flutter/material.dart';
import '/models/answer.dart';
import '/models/question_input.dart';
import 'question_input_widget.dart';


class BoolInput extends QuestionInputWidget<BoolAnswer> {
  const BoolInput({
    required QuestionInput definition,
    required AnswerController<BoolAnswer> controller,
    Key? key
  }) : super(definition: definition, controller: controller, key: key);


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        children: definition.values.entries.map<Widget>((entry) {
          final state = entry.key == 'true';

          return BoolInputItem(
            label:  Text(entry.value.name ?? (state ? 'Ja' : 'Nein')),
            onTap: () {
              _handleChange(state);
            },
            active: controller.answer?.value == state,
            color: theme.colorScheme.primary.withOpacity(0),
            activeColor: theme.colorScheme.primary,
            labelColor: theme.colorScheme.primary,
            activeIconColor: theme.colorScheme.onPrimary,
          );
        }).toList(),
        ),
    );
  }

  void _handleChange(bool selectedState) {
    controller.answer = controller.answer?.value != selectedState
      ? BoolAnswer(
        questionValues: definition.values,
        value: selectedState
      )
      : null;
  }
}

class BoolInputItem extends ImplicitlyAnimatedWidget {

  final Widget label;
  final bool active;
  final double widthFactor;
  final VoidCallback onTap;
  final Color? color, activeColor, labelColor, activeIconColor;

  const BoolInputItem({
    required this.label,
    required this.onTap,
    this.active = false,
    this.widthFactor = 0.45,
    this.color = Colors.white,
    this.activeColor = Colors.green,
    this.labelColor = Colors.green,
    this.activeIconColor = Colors.white,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.ease,
    Key? key,
  }) : super(key: key, duration: duration, curve: curve);

  @override
  AnimatedWidgetBaseState<BoolInputItem> createState() => _BoolInputItemState();
}

class _BoolInputItemState extends AnimatedWidgetBaseState<BoolInputItem> {
  ColorTween? _colorTween;

  ColorTween? _iconColorTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _colorTween = visitor(
        _colorTween,
        widget.active ? widget.activeColor : widget.color,
            (value) => ColorTween(begin: value)
    ) as ColorTween?;

    _iconColorTween = visitor(
        _iconColorTween,
        widget.active ? widget.activeIconColor : widget.labelColor,
            (value) => ColorTween(begin: value)
    ) as ColorTween?;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widget.widthFactor,
      child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            primary: _iconColorTween?.evaluate(animation),
            backgroundColor: _colorTween?.evaluate(animation),
          ),
          onPressed: widget.onTap,
          child: widget.label
      ),
    );
  }
}
