import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/models/answer.dart';
import 'question_bubble.dart';


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
    return QuestionBubble(
      padding: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            fit: FlexFit.tight,
            child: TextButton(
              style: ButtonStyle(
                textStyle:  MaterialStateProperty.all<TextStyle>(
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
              child: const Text('Zurück')
            ),
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
                    layoutBuilder: (currentChild, previousChildren) {
                      return Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          ...previousChildren,
                          if(currentChild != null) currentChild
                        ],
                      );
                    },
                    child: hasAnswer
                      ? const Text('Weiter', key: ValueKey(true), )
                      : const Text('Überspringen', key: ValueKey(false))
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
