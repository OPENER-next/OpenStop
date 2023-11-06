import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QuestionNavigationBar extends StatelessWidget {
  final String? nextText;
  final String? backText;
  final String? nextTextSemantics;
  final VoidCallback? onNext;
  final VoidCallback? onBack;

  const QuestionNavigationBar({
    this.nextText,
    this.backText,
    this.nextTextSemantics,
    this.onBack,
    this.onNext,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appLocale = AppLocalizations.of(context)!;
    final disabledButtonStyle = ButtonStyle(
      foregroundColor: MaterialStatePropertyAll(Theme.of(context).disabledColor),
      overlayColor: const MaterialStatePropertyAll(Colors.transparent),
      mouseCursor: const MaterialStatePropertyAll(SystemMouseCursors.forbidden),
      splashFactory: NoSplash.splashFactory,
      enableFeedback: false,
    );

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
              ? null
              : TextButton(
                // mimic disabled style
                style: onBack != null
                  ? _buttonStyle
                  : _buttonStyle.merge(disabledButtonStyle),
                // if button is disabled vibrate when pressed as additional feedback
                onPressed: onBack ?? HapticFeedback.vibrate,
                child: Semantics(
                  label: appLocale.xxxBackQuestionButtonLabel,
                  child: Row(
                    children: [
                      const Icon(Icons.chevron_left_rounded),
                      Text(backText!),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: nextText == null
              ? null
              : TextButton(
                key: ValueKey(nextText),
                // mimic disabled style
                style: onNext != null
                  ? _buttonStyle
                  : _buttonStyle.merge(disabledButtonStyle),
                // if button is disabled vibrate when pressed as additional feedback
                onPressed: onNext ?? HapticFeedback.vibrate,
                child: Semantics(
                  label: nextTextSemantics,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(nextText!),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _buttonStyle = ButtonStyle(
    textStyle: MaterialStatePropertyAll(
      TextStyle(
        fontSize: 13,
      ),
    ),
    padding: MaterialStatePropertyAll(
      EdgeInsets.all(20),
    ),
    alignment: Alignment.centerLeft,
    shape: MaterialStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
    ),
  );
}
