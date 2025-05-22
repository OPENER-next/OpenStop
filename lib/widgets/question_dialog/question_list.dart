import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class QuestionList extends StatefulWidget {
  final List<Widget> children;

  final int index;

  const QuestionList({
    required this.children,
    this.index = 0,
    super.key,
  });

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
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubicEmphasized,
    );

    _delegate = _QuestionListDelegate(_proxyAnimation);
    // set initial index as start
    _updateTweenAnimation(start: widget.index);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration = _duration;
  }

  Duration get _duration {
    // disable animation when screen reader is active
    return MediaQuery.of(context).accessibleNavigation
        ? Duration.zero
        : const Duration(milliseconds: 500);
  }

  @override
  void didUpdateWidget(covariant QuestionList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // set previous index/value as start
    _updateTweenAnimation(start: _proxyAnimation.value);
    // rerun animation
    _controller.value = 0;
    _controller.forward();
  }

  void _updateTweenAnimation({
    required num start,
  }) {
    _proxyAnimation.parent = _animation.drive(
      Tween<double>(
        begin: start.toDouble(),
        end: widget.index.toDouble(),
      ),
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
        return Semantics(
          container: true,
          sortKey: OrdinalSortKey(index.toDouble()),
          excludeSemantics: !isActive,
          child: IgnorePointer(
            // add child widget key on top to preserve state if needed
            key: child.key,
            ignoring: !isActive,
            child: AnimatedOpacity(
              alwaysIncludeSemantics: true,
              opacity: isActive || isFollowing ? 1 : 0,
              duration: _duration,
              curve: Curves.easeInOutCubicEmphasized,
              child: child,
            ),
          ),
        );
      }, growable: false),
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
  final Animation<double> indexAnimation;

  _QuestionListDelegate(this.indexAnimation) : super(repaint: indexAnimation);

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
    var indexOffset = 0.0;
    for (var i = 0; i <= flooredIndex; i++) {
      indexOffset += context.getChildSize(i)!.height;
    }

    final fraction = indexAnimation.value - indexAnimation.value.truncate();
    // calculate the fractional height of the child based on the current animation index
    // fraction will be zero at the end so this will rightfully do nothing
    indexOffset += context.getChildSize(ceiledIndex)!.height * fraction;

    var accumulatedOffset = 0.0;

    // only render widgets to the current (ceiled) active index for better performance
    for (var i = 0; i <= ceiledIndex; i++) {
      final childSize = context.getChildSize(i)!;

      // translate from top to bottom (out of view)
      var translate = viewSize.height;
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
