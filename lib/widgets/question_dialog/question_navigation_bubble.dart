import 'package:flutter/material.dart';

import 'question_bubble.dart';


class QuestionNavigationBubble extends StatelessWidget {
  final void Function()? onNext;
  final void Function()? onBack;

  QuestionNavigationBubble({
    this.onBack,
    this.onNext,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        QuestionBubble(
          padding: EdgeInsets.zero,
          color: Theme.of(context).colorScheme.surface,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                fit: FlexFit.tight,
                flex: 5,
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
              const Flexible(
                fit: FlexFit.tight,
                flex: 3,
                child: const SizedBox(
                  height: 30,
                  child: const VerticalDivider()
                ),
              ),
              Flexible(
                fit: FlexFit.tight,
                flex: 5,
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
                    alignment: Alignment.centerRight
                  ),
              onPressed: onNext,
              child: const Text('Weiter')
                ),
              )
            ],
          )
        ),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 600),
          reverseDuration: Duration(milliseconds: 300),
          switchInCurve: Curves.elasticOut,
          switchOutCurve: Curves.decelerate,
          transitionBuilder: _scaleTransitionBuilder,
          child: onConfirm == null
            ? SizedBox.square(dimension: 65, key: ValueKey(1))
            : SizedBox.square(dimension: 65, key: ValueKey(2),
              child: FloatingActionButton(
              // elevation: 0,
              onPressed: onConfirm,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.check,
                size: 40,
                color: Colors.white,
              ),
              shape: CircleBorder(),
            )
          )
        ),
      ]
    );
  }


  Widget _scaleTransitionBuilder(Widget child, Animation<double> animation) {
    return ScaleTransition(
      scale: animation,
      child: child
    );
  }
}