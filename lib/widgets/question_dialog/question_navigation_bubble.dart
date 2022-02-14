import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/view_models/questionnaire_provider.dart';
import '/models/answer.dart';


class QuestionNavigationBubble extends StatelessWidget {
  final void Function()? onNext;
  final void Function()? onBack;

  const QuestionNavigationBubble({
    this.onBack,
    this.onNext,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final questionnaire = context.watch<QuestionnaireProvider>();
    final hasPrevious = (questionnaire.activeIndex ?? 0) > 0;

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            fit: FlexFit.tight,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: (!hasPrevious)
              ? const SizedBox.shrink()
              : TextButton(
                style: ButtonStyle(
                  textStyle: MaterialStateProperty.all<TextStyle>(
                    const TextStyle(
                      fontSize: 13
                    )
                  ),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    const EdgeInsets.all(20),
                  ),
                  alignment: Alignment.centerLeft
                ),
                onPressed: onBack,
                child: Row(
                  children: const [
                    Icon(Icons.keyboard_arrow_left_rounded),
                    Text('Zurück'),
                  ],
                )
              ),
            )
          ),
          Flexible(
            fit: FlexFit.tight,
            child: TextButton(
              style: ButtonStyle(
                textStyle: MaterialStateProperty.all<TextStyle>(
                  const TextStyle(
                    fontSize: 13
                  )
                ),
                padding: MaterialStateProperty.all<EdgeInsets>(
                  const EdgeInsets.all(20),
                ),
                alignment: Alignment.centerRight
              ),
              onPressed: onNext,
              child: Selector<Answer?, bool>(
                selector: (_, answer) => answer != null,
                builder: (context, hasAnswer, child) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Row(
                      key: ValueKey(hasAnswer),
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(hasAnswer ? 'Weiter' : 'Überspringen'),
                        const Icon(Icons.keyboard_arrow_right_rounded)
                      ]
                    )
                  );
                },
              ),
            ),
          )
        ],
      )
    );
  }
}
