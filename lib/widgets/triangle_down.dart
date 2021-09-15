import 'package:flutter/material.dart';

class TriangleDown extends StatelessWidget {

  final Size size;

  final Widget? child;

  final Color color;

  const TriangleDown({this.size = Size.zero, this.color = Colors.black, this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: TrianglePainter(color: color),
      size: size,
      child: child
    );
  }
}


class TrianglePainter extends CustomPainter {
  final Color color;

  const TrianglePainter({this.color = Colors.black});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(getTrianglePath(size.width, size.height), paint);
  }

  Path getTrianglePath(double x, double y) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(x / 2, y)
      ..lineTo(x, 0)
      ..close();
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}