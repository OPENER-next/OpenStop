import 'package:flutter/material.dart';


class QuestionList extends StatefulWidget {
  final List<Widget> children;

  final int index;

  const QuestionList({
    required this.children,
    this.index = 0,
    Key? key
  }) : super(key: key);

  @override
  State<QuestionList> createState() => _QuestionListState();
}


class _QuestionListState extends State<QuestionList> with SingleTickerProviderStateMixin {
  final _proxyAnimation = ProxyAnimation();

  late final AnimationController _controller;

  late final CurvedAnimation _animation;

  late final _QuestionListDelegate _delegate;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500)
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubicEmphasized
    );

    _delegate = _QuestionListDelegate(_proxyAnimation);

    _updateTweenAnimation();
  }


  @override
  void didUpdateWidget(covariant QuestionList oldWidget) {
    super.didUpdateWidget(oldWidget);

    _updateTweenAnimation();
    // rerun animation
    _controller.value = 0;
    _controller.forward();
  }


  void _updateTweenAnimation() {
    _proxyAnimation.parent = _animation.drive(
      Tween<double>(
        // this will be 0 the first time
        begin: _proxyAnimation.value,
        end: widget.index.toDouble()
      )
    );
  }


  @override
  Widget build(BuildContext context) {
    return Flow(
      clipBehavior: Clip.none,
      delegate: _delegate,
      children: List.generate(widget.children.length, (index) {
        final isActive = index == widget.index;
        final isFollowing = widget.index < index;
        final child = widget.children[index];

        return IgnorePointer(
          // add child widget key on top to preserve state if needed
          key: child.key,
          ignoring: !isActive,
          child: AnimatedOpacity(
            opacity: isActive || isFollowing ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            // don't remove decorated box entirely to keep state
            child: DecoratedBox(
              decoration: BoxDecoration(
                // only add shadow to active element
                boxShadow: !isActive ? null : [
                  BoxShadow(
                    color: Theme.of(context).shadowColor,
                    blurRadius: 2,
                    offset: const Offset(0, -2)
                  )
                ]
              ),
              child: child,
            )
          )
        );
      }, growable: false)
    );
  }


  @override
  void dispose() {
    _controller.dispose();
    _animation.dispose();
    super.dispose();
  }
}


class _QuestionListDelegate extends FlowDelegate {
  final Animation<double>  indexAnimation;

  _QuestionListDelegate(this.indexAnimation,) : super(repaint: indexAnimation);

  @override
  bool shouldRepaint(_QuestionListDelegate oldDelegate) {
    return true;
  }

  @override
  bool shouldRelayout(covariant FlowDelegate oldDelegate) {
    return false;
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    final viewSize = context.size;

    final flooredIndex = indexAnimation.value.floor();
    final ceiledIndex = indexAnimation.value.ceil();

    // sum all child heights that are below the current animation index
    double indexOffset = 0;
    for (var i = 0; i <= flooredIndex; i++) {
      indexOffset += context.getChildSize(i)!.height;
    }

    final fraction = indexAnimation.value - indexAnimation.value.truncate();
    // calculate the fractional height of the child based on the current animation index
    // fraction will be zero at the end so this will rightfully do nothing
    indexOffset += context.getChildSize(ceiledIndex)!.height * fraction;

    double accumulatedOffset = 0;

    // only render widgets to the current (ceiled) active index for better performance
    for (int i = 0; i <= ceiledIndex; i++) {
      final childSize = context.getChildSize(i)!;

      // translate from top to bottom (out of view)
      double translate = viewSize.height;
      // translate every child adjacent to its previous child
      translate += accumulatedOffset;
      // sum child heights
      accumulatedOffset += childSize.height;
      // offset each child by the current active index
      translate -= indexOffset;

      // Note: One could implement some performance improvements by only rendering widgets inside the visible area.
      // However in this case widgets should also be drawn outside of their view area (notice the Clip.none in the QuestionList widget)
      // This is why this is not implemented here.
      final transformationMatrix = Matrix4.translationValues(0, translate, 0);
      context.paintChild(i, transform: transformationMatrix);
    }
  }
}
