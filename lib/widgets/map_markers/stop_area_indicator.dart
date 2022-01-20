import 'dart:math';
import 'package:flutter/material.dart';

class StopAreaIndicator extends StatefulWidget {
  final double size;

  final Duration duration;

  final void Function()? onTap;

  final bool isLoading;

  const StopAreaIndicator({
    this.size = 100,
    this.duration = const Duration(seconds: 3),
    this.isLoading = false,
    this.onTap,
    Key? key
  }) : super(key: key);

  @override
  State<StopAreaIndicator> createState() => _StopAreaIndicatorState();
}


class _StopAreaIndicatorState extends State<StopAreaIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  late final scaleAnimation = CurvedAnimation(
    parent: _controller,
    curve: const Interval(
      0,
      0.8,
      curve: Curves.linearToEaseOut
    ),
  );

  late final opacityAnimation = CurvedAnimation(
    parent: Tween(begin: 1.0, end: 0.0).animate(_controller),
    curve: const Interval(
      0.5,
      1,
      curve: Curves.linear
    ),
  );


  @override
  void initState() {
    super.initState();

    if (widget.isLoading) {
      _controller.repeat();
    }
  }


  @override
  void didUpdateWidget(covariant StopAreaIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isLoading != widget.isLoading) {
      widget.isLoading
      ? _controller.repeat()
      : _controller.forward(from: _controller.value);
    }
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      // this is used to provider proper hit testing because currently it cannot be done in the CustomPainter
      // see: https://github.com/flutter/flutter/issues/28206
      child: ClipOval(
        child: CustomPaint(
          painter: CirclePainter(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            strokeWidth: 0
          ),
          size: Size.square(widget.size),
          child: _controller.isAnimating
            ? FadeTransition(
                opacity: opacityAnimation,
                child: ScaleTransition(
                  scale: scaleAnimation,
              child: CustomPaint(
                painter: CirclePainter(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.4)
                ),
              )
                )
            )
            : null
        )
      )
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}


class CirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final Color strokeColor;

  const CirclePainter({
    this.color = Colors.black,
    this.strokeColor = Colors.transparent,
    this.strokeWidth = 2
  });

  @override
  void paint(Canvas canvas, Size size) {
    final halfWidth = size.width/2;
    final halfHeight = size.height/2;
    final offset = Offset(halfWidth, halfHeight);
    final radius = min(halfWidth, halfHeight);

    if (color != Colors.transparent) {
      canvas.drawCircle(
        offset,
        radius,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill
      );
    }

    if (strokeColor != Colors.transparent && strokeWidth > 0) {
      canvas.drawCircle(
      offset,
      // make stroke width inset
      radius - strokeWidth/2,
      Paint()
        ..color = strokeColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
      );
    }
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) =>
    oldDelegate.color != color ||
    oldDelegate.strokeColor != strokeColor ||
    oldDelegate.strokeWidth != strokeWidth;
}
