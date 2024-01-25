// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

/// Clips the given object vertically or horizontally.
class ClipSymmetric extends CustomClipper<Rect> {
  final MediaQueryData mediaQuery;

  final Axis direction;

  const ClipSymmetric({
    required this.mediaQuery,
    this.direction = Axis.vertical,
  });

  @override
  Rect getClip(Size size) {
    final logicalScreenSize = mediaQuery.size;
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
