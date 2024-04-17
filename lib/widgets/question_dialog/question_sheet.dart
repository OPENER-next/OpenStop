import 'package:flutter/material.dart';


class QuestionSheet extends StatelessWidget {
  final Widget header;

  final Widget body;

  final bool elevate;

  const QuestionSheet({
    required this.header,
    required this.body,
    this.elevate = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        boxShadow: !elevate ? null : kElevationToShadow[4]
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          Flexible(
            child: body,
          ),
        ],
      ),
    );
  }
}
