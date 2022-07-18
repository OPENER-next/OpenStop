import 'package:flutter/material.dart';

/// Clips the given object vertically or horizontally.
class ClipSymmetric extends CustomClipper<Rect> {
  final Axis direction;

  const ClipSymmetric({
    this.direction = Axis.vertical
  });

  @override
  Rect getClip(Size size) {
    final logicalScreenSize = MediaQueryData.fromWindow(WidgetsBinding.instance.window).size;

    return Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: direction == Axis.vertical
            ? logicalScreenSize.width
            : size.width,
        height: direction == Axis.horizontal
            ? logicalScreenSize.height
            : size.height
    );
  }

  @override
  bool shouldReclip(ClipSymmetric oldClipper) => oldClipper.direction != direction;
}
