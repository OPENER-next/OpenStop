import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// The rotation/heading will implicitly animate whenever it changes.

class LocationIndicator extends ImplicitlyAnimatedWidget {
  final Color color;
  final Color strokeColor;

  /// The value is expected to be in radians.

  final double heading;

  final Size size;

  /// The value is expected to be in radians.
  /// Setting this to 0 will hide the sector.

  final double sectorSize;

  const LocationIndicator({
    Key? key,
    this.color = Colors.blue,
    this.strokeColor = Colors.white,
    this.size = Size.infinite,
    this.sectorSize = pi/2,
    this.heading = 0,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.ease
  }) : super(key: key, duration: duration, curve: curve);

   @override
  _LocationIndicatorState createState() => _LocationIndicatorState();
}

class _LocationIndicatorState extends AnimatedWidgetBaseState<LocationIndicator> {
  RotationTween? _rotationTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _rotationTween = visitor(
      _rotationTween,
      widget.heading,
      (value) => RotationTween(begin: value)
    ) as RotationTween;
  }

  @override
  Widget build(context) {
    return Transform.rotate(
      alignment: Alignment.center,
      angle: _rotationTween?.evaluate(animation) ?? _rotationTween?.begin ?? 0,
      child: CustomPaint(
        painter: LocationIndicatorPainter(
          color: widget.color,
          strokeColor: widget.strokeColor,
          sectorSize: widget.sectorSize
        ),
        size: widget.size,
      ),
    );
  }
}


/// Interpolate radians values in the direction of the shortest rotation delta / rotation angle.

class RotationTween extends Tween<double> {
  static const piDoubled = pi * 2;

  RotationTween({ double? begin, double? end }) : super(begin: begin, end: end);

  @override
  double lerp(double t) {
    // thanks to https://stackoverflow.com/questions/2708476/rotation-interpolation
    double rotationDelta = ((end! - begin!) + pi) % piDoubled - pi;
    return begin! + rotationDelta * t;
  }
}


class LocationIndicatorPainter extends CustomPainter {
  final Color color;
  final Color strokeColor;

  /// The value is expected to be in radians.
  /// Setting this to 0 will hide the sector.

  final double sectorSize;

  const LocationIndicatorPainter({
    this.color = Colors.black,
    this.strokeColor = Colors.black,
    this.sectorSize = pi/2
  });


  @override
  void paint(Canvas canvas, Size size) {
    final offset = Offset(size.width/2, size.height/2);

    final outerRadius = min(offset.dx, offset.dy);
    final innerRadius = outerRadius / 6;

    // draw sector

    if (sectorSize > 0) {
      final outerRect = Rect.fromCircle(
        center: offset,
        radius: outerRadius,
      );

      canvas.drawArc(
        outerRect,
        -pi/2 - sectorSize/2,
        sectorSize,
        true,
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withOpacity(color.opacity * 1.0),
              color.withOpacity(color.opacity * 0.6),
              color.withOpacity(color.opacity * 0.3),
              color.withOpacity(color.opacity * 0.1),
              color.withOpacity(color.opacity * 0.0),
            ],
          ).createShader(outerRect),
      );
    }

    // draw shadow

    final innerRect = Rect.fromCircle(
      center: offset,
      radius: innerRadius,
    );

    canvas.drawShadow(
      Path()..addOval(innerRect),
      Colors.black,
      4,
      true
    );

    // draw circle

    canvas.drawCircle(
      offset,
      innerRadius,
      Paint()
        ..color = this.color
        ..style = PaintingStyle.fill
    );

    canvas.drawCircle(
      offset,
      innerRadius,
      Paint()
        ..color = strokeColor
        ..strokeWidth = innerRadius / 2
        ..style = PaintingStyle.stroke
    );
  }

  @override
  bool shouldRepaint(LocationIndicatorPainter oldDelegate) =>
    oldDelegate.color != color ||
    oldDelegate.strokeColor != strokeColor ||
    oldDelegate.sectorSize != sectorSize;
}