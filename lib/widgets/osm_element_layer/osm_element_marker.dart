import 'dart:math';

import 'package:flutter/material.dart';

class OsmElementMarker extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final Color? backgroundColor;

  const OsmElementMarker({
    Key? key,
    this.onTap,
    this.icon = Icons.block,
    this.backgroundColor
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    // add repaint boundary for performance improvement
    // this way a marker will only be redrawn if it self changes
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: FractionalTranslation(
                translation: const Offset(0, 0.5),
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  heightFactor: 0.175,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.shadow,
                          blurRadius: 4
                        )
                      ]
                    )
                  ),
                ),
              )
            ),
            CustomPaint(
              painter: MarkerPinPainter(
                color: backgroundColor ?? Theme.of(context).colorScheme.primary,
                strokeColor: Colors.white,
                icon: icon
              ),
              isComplex: true,
              willChange: false,
            ),
          ],
        )
      )
    );
  }
}


class MarkerPinPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final Color strokeColor;
  final Color shadowColor;
  final int tipHeight;
  final double tipAngle;
  final IconData icon;
  final double iconScale;

  const MarkerPinPainter({
    required this.icon,
    this.color = Colors.black,
    this.strokeColor = Colors.black,
    this.shadowColor = Colors.black12,
    this.strokeWidth = 6,
    this.tipHeight = 7,
    this.tipAngle = 0.6,
    this.iconScale = 0.6,
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
          color: strokeColor,
          fontSize: availableHeight * iconScale,
          fontFamily: icon.fontFamily,
          shadows: [
            Shadow(
              color: shadowColor,
              blurRadius: 0,
              offset: const Offset(2, 2)
            )
          ]
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
