import 'package:flutter/material.dart';


class QuestionSheet extends StatelessWidget {
  final Widget child;

  final bool elevate;

  const QuestionSheet({
    required this.child,
    this.elevate = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        boxShadow: !elevate ? null : [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, -2)
          )
        ]
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: child
      )
    );
  }
}
