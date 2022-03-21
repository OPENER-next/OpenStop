import 'package:flutter/material.dart';
import '/models/answer.dart';
import '/models/question_input.dart';
import 'question_input_widget.dart';


class BoolInput extends QuestionInputWidget {
  const BoolInput(
      QuestionInput questionInput,
      { AnswerController? controller, Key? key }
      ) : super(questionInput, controller: controller, key: key);

  @override
  _BoolInputState createState() => _BoolInputState();
}


class _BoolInputState extends QuestionInputWidgetState {
  bool? _selectedBool;

  late final ColorScheme theme = Theme.of(context).colorScheme;

  @override
  void initState() {
    super.initState();
    _selectedBool = widget.controller?.answer?.value;
  }

  void _toggleState(bool state) {
    setState(() {
      _selectedBool = _selectedBool != state ? state : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        children: widget.questionInput.values.entries.map<Widget>((entry) {
          final state = entry.key == 'true';

          return BoolInputItem(
            label:  Text(entry.value.name ?? (state ? 'Ja' : 'Nein')),
            onTap: () {
              _toggleState(state);
              _handleChange();
            },
            active: _selectedBool == state,
            color: theme.primary.withOpacity(0),
            activeColor: theme.primary,
            labelColor: theme.primary,
            activeIconColor: theme.onPrimary,
          );
        }).toList(),
        ),
    );
  }

  void _handleChange() {
    widget.controller?.answer = _selectedBool != null
      ? BoolAnswer(
        questionValues: widget.questionInput.values,
        value: _selectedBool!
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
          child: widget.label,
          style: OutlinedButton.styleFrom(
            primary: _iconColorTween?.evaluate(animation),
            backgroundColor: _colorTween?.evaluate(animation),
          ),
          onPressed: widget.onTap
      ),
    );
  }
}
