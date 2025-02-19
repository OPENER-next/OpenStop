import 'package:flutter/material.dart';

import '/l10n/app_localizations.dart';
import '/models/answer.dart';
import '/models/question_catalog/answer_definition.dart';
import 'list_input.dart';
import 'question_input_widget.dart';


class MultiListInput extends QuestionInputWidget<MultiListAnswerDefinition, MultiListAnswer> {
  const MultiListInput({
    required super.definition,
    required super.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final appLocale = AppLocalizations.of(context)!;
    return Wrap(
      runSpacing: 8.0,
      children: List.generate(definition.input.length, (index) {
        final item = definition.input[index];
        return ListInputItem(
          active: controller.answer?.value.contains(index) ?? false,
          label: item.name,
          description: item.description,
          imagePath: item.image,
          onTap: () => _handleChange(index, appLocale),
          isMultiList: true,
        );
      }, growable: false),
    );
  }

  void _handleChange(int selectedIndex, AppLocalizations appLocale) {
    final List<int> newValue;
    final isSelected = controller.answer?.value.contains(selectedIndex) ?? false;
    if (isSelected) {
      newValue = controller.answer!.value
        .where((index) => selectedIndex != index)
        .toList(growable: false);
    }
    else {
      newValue = [
        ...?controller.answer?.value,
        selectedIndex,
      ];
    }

    controller.answer = newValue.isNotEmpty
      ? MultiListAnswer(
        definition: definition,
        value: newValue
      )
      : null;
  }
}
