
import 'package:flutter/material.dart';

import 'question_bubble.dart';


class QuestionTextBubble extends StatefulWidget {
  final String question;

  final String details;

  QuestionTextBubble({
    Key? key,
    required this.question,
    required this.details
  }) : super(key: key);

  @override
  State<QuestionTextBubble> createState() => _QuestionTextBubbleState();
}

class _QuestionTextBubbleState extends State<QuestionTextBubble> with SingleTickerProviderStateMixin {
  bool _selected = false;

  late final _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
    reverseDuration: const Duration(milliseconds: 500)
  );

  late final _sizeAnimation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeInOutCubicEmphasized,
    reverseCurve: Curves.easeInCubic
  );

  late final _fadeAnimation = CurvedAnimation(
    parent: _animationController,
    curve: const Interval(0, 0.5),
    reverseCurve: const Interval(0.5, 1)
  );

  late final _fillColorAnimation = ColorTween(
    begin: Theme.of(context).colorScheme.secondary,
    end: Theme.of(context).colorScheme.primary
  ).animate(
    CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0, 0.3),
      reverseCurve: const Interval(0.5, 1)
    )
  );

  late final _iconColorAnimation = ColorTween(
    begin: Theme.of(context).colorScheme.onSecondary,
    end: Theme.of(context).colorScheme.onPrimary
  ).animate(
    CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0, 0.3),
      reverseCurve: const Interval(0.5, 1)
    )
  );


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.details.isEmpty ? null : () {
        _selected = !_selected;
        if (_selected) {
          _animationController.forward();
        }
        else {
          _animationController.reverse();
        }
      },
      child: QuestionBubble(
        topLeft: Radius.zero,
        color: Theme.of(context).colorScheme.surface,
        margin: const EdgeInsets.only(bottom: 10),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: const TextStyle(
                      height: 1.3,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                if (widget.details.isNotEmpty) AnimatedBuilder(
                  animation: _fillColorAnimation,
                  builder: (context, child) {
                    return Container(
                      margin: const EdgeInsets.only(left: 5),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _fillColorAnimation.value!,
                        shape: BoxShape.circle
                      ),
                      child: Text(
                        'i',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _iconColorAnimation.value!,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Times"
                        )
                      )
                    );
                  },
                )
              ]
            ),
            if (widget.details.isNotEmpty) SizeTransition(
              axisAlignment: -1,
              sizeFactor: _sizeAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    widget.details,
                    style: const TextStyle(
                      fontSize: 12,
                    )
                  ),
                )
              )
            )
          ],
        )
      ),
    );
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
