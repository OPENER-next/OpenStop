import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class OsmElementMarker extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;

  const OsmElementMarker({
    Key? key,
    this.onTap,
    this.icon = Icons.block,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: MarkerPinPainter(
          color: Theme.of(context).colorScheme.primary,
          strokeColor: Colors.white,
          icon: icon
        ),
      ),
    );
  }
}


class MarkerPinPainter extends CustomPainter {
  static const skewX = 0.5;
  static const scaleY = 0.4;
  static const scaleX = 1.0;

  final Color color;
  final double strokeWidth;
  final Color strokeColor;
  final int tipHeight;
  final double tipAngle;
  final IconData icon;
  final double iconScale;

  const MarkerPinPainter({
    required this.icon,
    this.color = Colors.black,
    this.strokeColor = Colors.black,
    this.strokeWidth = 6,
    this.tipHeight = 9,
    this.tipAngle = 0.6,
    this.iconScale = 0.75,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final availableHeight = size.shortestSide - tipHeight;
    final circleRadius = availableHeight / 2;
    final circleCenter = size.topCenter(Offset(0, circleRadius));

    final path = Path()
      ..arcTo(
        Rect.fromCircle(center: circleCenter, radius: circleRadius),
        (pi + tipAngle) / 2,
        2 * pi - tipAngle,
        false
      )
      ..lineTo(circleCenter.dx, size.height)
      ..close();

    final transformedPath = path.transform(Float64List.fromList([
      scaleX, 0, 0, 0,
      skewX, scaleY, 0, 0,
      0, 0, 1, 0,
      0, 0, 0, 1
    ]));

    // TODO: The shadow currently overflows the canvas rect.
    // While this works on android Flutter doc explicitly states that this is not guaranteed to work on every platform.
    // Therefore figure out a good solution to draw the shadow (for example by using a stack and a separate painter)

    canvas.drawShadow(
      transformedPath.shift(Offset(
        -size.width * skewX + size.width/2 * (1 - scaleX),
        size.height * (1 - scaleY))
      ),
      Colors.black87,
      2.0, true
    );

    // paint outer border with tip
    canvas.drawPath(
      path,
      Paint()
        ..color = strokeColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.fill
    );

    // paint inner circle
    if (color != Colors.transparent) {
      canvas.drawCircle(
        circleCenter,
        circleRadius - strokeWidth / 2,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill
      );
    }

    // paint icon
    final textPainter = TextPainter(textDirection: TextDirection.rtl)
      ..text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: availableHeight * iconScale,
          fontFamily: icon.fontFamily
        )
      );
    textPainter.layout();
    textPainter.paint(canvas, circleCenter - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  @override
  bool shouldRepaint(MarkerPinPainter oldDelegate) =>
    oldDelegate.color != color ||
    oldDelegate.strokeColor != strokeColor ||
    oldDelegate.strokeWidth != strokeWidth ||
    oldDelegate.tipHeight != tipHeight ||
    oldDelegate.tipAngle != tipAngle ||
    oldDelegate.iconScale != iconScale ||
    oldDelegate.icon != icon;
}
