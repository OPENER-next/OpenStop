import 'package:flutter/material.dart';

class QuestionNavigationBar extends StatelessWidget {
  final String? nextText;
  final String? backText;

  final void Function()? onNext;
  final void Function()? onBack;

  const QuestionNavigationBar({
    this.nextText,
    this.backText,
    this.onBack,
    this.onNext,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: backText == null
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
                  alignment: Alignment.centerLeft,
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero
                      )
                  )
                ),
                onPressed: onBack,
                child: Row(
                  children: [
                    const Icon(Icons.chevron_left_rounded),
                    Text(backText!),
                  ],
                )
              ),
            )
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: nextText == null
              ? const SizedBox.shrink()
              : TextButton(
                key: ValueKey(nextText),
                style: ButtonStyle(
                  textStyle: MaterialStateProperty.all<TextStyle>(
                    const TextStyle(
                      fontSize: 13
                    )
                  ),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    const EdgeInsets.all(20),
                  ),
                  alignment: Alignment.centerRight,
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero
                      )
                  )
                ),
                onPressed: onNext,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(nextText!),
                    const Icon(Icons.chevron_right_rounded)
                  ]
                )
              )
            ),
          )
        ],
      )
    );
  }
}
