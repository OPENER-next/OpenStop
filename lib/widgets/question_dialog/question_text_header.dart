import 'package:flutter/material.dart';

class QuestionTextHeader extends StatefulWidget {
  final String question;

  final String details;

  const QuestionTextHeader({
    required this.question,
    required this.details,
    Key? key
  }) : super(key: key);

  @override
  State<QuestionTextHeader> createState() => _QuestionTextHeaderState();
}

class _QuestionTextHeaderState extends State<QuestionTextHeader> with SingleTickerProviderStateMixin {
  bool _selected = false;

  late final AnimationController _animationController;

  late final CurvedAnimation _sizeAnimation;

  late final CurvedAnimation _fadeAnimation;

  late Animation<Color?> _fillColorAnimation;

  late Animation<Color?>_iconColorAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      reverseDuration: const Duration(milliseconds: 500)
    );

    _sizeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubicEmphasized,
      reverseCurve: Curves.easeInCubic
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0, 0.5),
      reverseCurve: const Interval(0.5, 1)
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _fillColorAnimation = ColorTween(
      begin: Theme.of(context).colorScheme.secondary,
      end: Theme.of(context).colorScheme.primary
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.3),
        reverseCurve: const Interval(0.5, 1)
      )
    );

    _iconColorAnimation = ColorTween(
      begin: Theme.of(context).colorScheme.onSecondary,
      end: Theme.of(context).colorScheme.onPrimary
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.3),
        reverseCurve: const Interval(0.5, 1)
      )
    );
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.details.isEmpty ? null : () {
        _selected = !_selected;
        if (_selected) {
          _animationController.forward();
        }
        else {
          _animationController.reverse();
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(
          top: 25,
          left: 20,
          right: 20,
          bottom: 20
        ),
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
                          fontFamily: 'Times'
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
