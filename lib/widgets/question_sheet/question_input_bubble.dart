
import 'package:flutter/material.dart';

import 'question_bubble.dart';


class QuestionInputBubble extends StatelessWidget {
  final Widget child;

  QuestionInputBubble({
    Key? key,
    required this.child
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QuestionBubble(
      topRight: Radius.zero,
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 10),
      child: child
    );
  }
}
