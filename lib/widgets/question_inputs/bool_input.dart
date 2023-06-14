// ignore_for_file: unused_element
// required till https://github.com/dart-lang/sdk/issues/48401 is resolved

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/models/answer.dart';
import '/models/question_catalog/answer_definition.dart';
import 'question_input_widget.dart';


class BoolInput extends QuestionInputWidget<BoolAnswerDefinition, BoolAnswer> {
  const BoolInput({
    required super.definition,
    required super.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        children: List.generate(2, (index) {
          final state = index == 0;
          return _BoolInputItem(
            label:  Text(definition.input[index].name ?? 
                    (state ? AppLocalizations.of(context)!.yes : AppLocalizations.of(context)!.no)),
            onTap: () => _handleChange(state),
            active: controller.answer?.value == state,
            backgroundColor: theme.colorScheme.primary.withOpacity(0),
            activeBackgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.primary,
            activeForegroundColor: theme.colorScheme.onPrimary,
          );
        }, growable: false),
      ),
    );
  }

  void _handleChange(bool selectedState) {
    controller.answer = controller.answer?.value != selectedState
      ? BoolAnswer(
        definition: definition,
        value: selectedState
      )
      : null;
  }
}


class _BoolInputItem extends ImplicitlyAnimatedWidget {
  final Widget label;
  final bool active;
  final double widthFactor;
  final Color backgroundColor, activeBackgroundColor, foregroundColor, activeForegroundColor;
  final VoidCallback onTap;

  const _BoolInputItem({
    required this.label,
    required this.onTap,
    this.active = false,
    this.widthFactor = 0.45,
    this.backgroundColor = Colors.white,
    this.activeBackgroundColor = Colors.green,
    this.foregroundColor = Colors.green,
    this.activeForegroundColor = Colors.white,
    super.duration = const Duration(milliseconds: 300),
    super.curve = Curves.ease,
    super.key,
  });

  @override
  AnimatedWidgetBaseState<_BoolInputItem> createState() => _BoolInputItemState();
}

class _BoolInputItemState extends AnimatedWidgetBaseState<_BoolInputItem> {
  ColorTween? _backgroundColorTween, _foregroundColorTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _backgroundColorTween = visitor(
      _backgroundColorTween,
      widget.active ? widget.activeBackgroundColor : widget.backgroundColor,
      (value) => ColorTween(begin: value)
    ) as ColorTween?;

    _foregroundColorTween = visitor(
      _foregroundColorTween,
      widget.active ? widget.activeForegroundColor : widget.foregroundColor,
      (value) => ColorTween(begin: value)
    ) as ColorTween?;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widget.widthFactor,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: _foregroundColorTween?.evaluate(animation),
          backgroundColor: _backgroundColorTween?.evaluate(animation),
        ),
        onPressed: widget.onTap,
        child: widget.label,
      ),
    );
  }
}
