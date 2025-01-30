import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class QuestionNavigationBar extends StatelessWidget {
  final String? nextText;
  final String? backText;
  final String? nextTextSemantics;
  final String? backTextSemantics;
  final VoidCallback? onNext;
  final VoidCallback? onBack;

  const QuestionNavigationBar({
    this.nextText,
    this.backText,
    this.nextTextSemantics,
    this.backTextSemantics,
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
                : Semantics(
                  container: true,
                  sortKey: const OrdinalSortKey(2.0, name: 'questionNavigation'),
                  child: TextButton.icon(
                    // mimic disabled style
                    style: onBack != null
                      ? _buttonStyle.merge(const ButtonStyle(alignment: Alignment.centerLeft))
                      : _buttonStyle.merge(const ButtonStyle(alignment: Alignment.centerLeft)).merge(disabledButtonStyle),
                    // if button is disabled vibrate when pressed as additional feedback
                    onPressed: onBack ?? HapticFeedback.vibrate,
                    label: const Icon(Icons.chevron_left_rounded),
                    icon: Text(
                      backText!,
                      semanticsLabel: backTextSemantics,
                    ),
                    iconAlignment: IconAlignment.end,
                  ),
                ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: nextText == null
                ? null
                : Semantics(
                  container: true,
                  sortKey: const OrdinalSortKey(1.0, name: 'questionNavigation'),
                  child: TextButton.icon(
                    key: ValueKey(nextText),
                    // mimic disabled style
                    style: onNext != null
                      ? _buttonStyle.merge(const ButtonStyle(alignment: Alignment.centerRight))
                      : _buttonStyle.merge(const ButtonStyle(alignment: Alignment.centerRight)).merge(disabledButtonStyle),
                    // if button is disabled vibrate when pressed as additional feedback
                    onPressed: onNext ?? HapticFeedback.vibrate,
                    isSemanticButton: false, // TODO this is only avilable for the normal button constructor...
                    label: Semantics(
                      button: true,
                      enabled: onNext != null,
                      child: Text(
                        nextText!,
                        semanticsLabel: nextTextSemantics,
                      ),
                    ),
                    icon: const Icon(Icons.chevron_right_rounded),
                    iconAlignment: IconAlignment.end,
                  ),
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
