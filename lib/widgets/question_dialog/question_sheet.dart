import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';


class QuestionSheet extends StatelessWidget {
  final Widget header;

  final Widget body;

  /// This does:
  /// - visually elevate the sheet
  /// - move the accessibility focus to this question
  final bool active;

  const QuestionSheet({
    required this.header,
    required this.body,
    this.active = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: !active ? null : kElevationToShadow[4]
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            container: true,
            sortKey: const OrdinalSortKey(1.0, name: 'QuestionSheet'),
            child: SemanticsFocus(
              focus: active,
              child: header,
            ),
          ),
          Flexible(
            child: Semantics(
              container: true,
              sortKey: const OrdinalSortKey(2.0, name: 'QuestionSheet'),
              child: body
            ),
          ),
        ],
      ),
    );
  }
}


/// Used to programmatically move the focus to a semantics node.
class SemanticsFocus extends StatefulWidget {
  final Widget child;
  final bool focus;

  const SemanticsFocus({
    required this.child,
    this.focus = false,
    super.key,
  });

  @override
  State<SemanticsFocus> createState() => _SemanticsFocusState();
}

class _SemanticsFocusState extends State<SemanticsFocus> {
  @override
  void didUpdateWidget(covariant SemanticsFocus oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.focus && widget.focus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.findRenderObject()?.sendSemanticsEvent(const FocusSemanticEvent());
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
