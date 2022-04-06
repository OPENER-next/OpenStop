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
        color: Colors.white,
        boxShadow: !elevate ? null : const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, -2)
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
