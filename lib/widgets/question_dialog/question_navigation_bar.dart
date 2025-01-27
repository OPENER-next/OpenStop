import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuestionNavigationBar extends StatelessWidget {
  final String? nextText;
  final String? backText;

  final VoidCallback? onNext;
  final VoidCallback? onBack;

  const QuestionNavigationBar({
    this.nextText,
    this.backText,
    this.onBack,
    this.onNext,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final disabledButtonStyle = ButtonStyle(
      foregroundColor: WidgetStatePropertyAll(Theme.of(context).disabledColor),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.forbidden),
      iconColor: WidgetStatePropertyAll(Theme.of(context).disabledColor),
      splashFactory: NoSplash.splashFactory,
      enableFeedback: false,
    );

    return Container(
      color: Theme.of(context).colorScheme.surface,
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
              : TextButton.icon(
                // mimic disabled style
                style: onBack != null
                  ? _buttonStyle.merge(const ButtonStyle(alignment: Alignment.centerLeft))
                  : _buttonStyle.merge(const ButtonStyle(alignment: Alignment.centerLeft)).merge(disabledButtonStyle),
                // if button is disabled vibrate when pressed as additional feedback
                onPressed: onBack ?? HapticFeedback.vibrate,
                label: const Icon(Icons.chevron_left_rounded),
                icon: Text(backText!),
                iconAlignment: IconAlignment.end,
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: nextText == null
              ? null
              : TextButton.icon(
                key: ValueKey(nextText),
                // mimic disabled style
                style: onNext != null
                  ? _buttonStyle.merge(const ButtonStyle(alignment: Alignment.centerRight))
                  : _buttonStyle.merge(const ButtonStyle(alignment: Alignment.centerRight)).merge(disabledButtonStyle),
                // if button is disabled vibrate when pressed as additional feedback
                onPressed: onNext ?? HapticFeedback.vibrate,
                label: Text(nextText!),
                icon: const Icon(Icons.chevron_right_rounded),
                iconAlignment: IconAlignment.end,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _buttonStyle = ButtonStyle(
    textStyle: WidgetStatePropertyAll(
      TextStyle(
        fontSize: 13,
      ),
    ),
    padding: WidgetStatePropertyAll(
      EdgeInsets.all(20),
    ),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
    ),
    minimumSize: WidgetStatePropertyAll(Size(double.infinity,0)),
  );
}
