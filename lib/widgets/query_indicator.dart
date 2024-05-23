import 'dart:math';

import 'package:flutter/material.dart';

import '/commons/custom_icons/custom_icons_icons.dart';

class QueryIndicator extends StatefulWidget {
  final bool active;

  const QueryIndicator({
    required this.active,
    super.key,
  });

  @override
  State<QueryIndicator> createState() => _QueryIndicatorState();
}

class _QueryIndicatorState extends State<QueryIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _animation = _controller.drive(_CircleTween(0.15));
    _triggerBounce();
  }

  @override
  void didUpdateWidget(covariant QueryIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    _triggerBounce();
  }

  void _triggerBounce() {
    if (widget.active && !_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.active ? 1 : 0,
      onEnd: () {
        if (!widget.active) _controller.reset();
      },
      duration: const Duration(milliseconds: 500),
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          Theme.of(context).brightness == Brightness.dark
            ? Colors.black45
            : Colors.black26,
          BlendMode.srcOut,
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          // required hack to make ColorFilter work for the entire container
          // because if it is fully transparent it is only applied to the Icon painting rect
          // might be related to https://github.com/flutter/flutter/pull/72526#issuecomment-749185938
          color: const Color.fromARGB(1, 255, 255, 255),
          padding: const EdgeInsets.all(70),
          child: FittedBox(
            child: SlideTransition(
              position: _animation,
              child: const Icon(
                CustomIcons.magnifierFilled,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}


class _CircleTween extends Tween<Offset> {
  final double distance;

  _CircleTween(this.distance) : super(
    begin: Offset.zero,
    end: Offset.fromDirection(2 * pi, distance)
  );

  @override
  Offset lerp(t) => Offset.fromDirection(2 * pi * t, distance);
}
