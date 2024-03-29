import 'package:flutter/material.dart';


class QuestionSheet extends StatelessWidget {
  final Widget child;

  final bool elevate;

  const QuestionSheet({
    required this.child,
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
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: child
      )
    );
  }
}
