import 'package:flutter/material.dart';

/// Clips the given object vertically.
class ClipVertical extends CustomClipper<Rect> {
  final BuildContext screenSpace;

  const ClipVertical({
    required this.screenSpace,
  });

  @override
  Rect getClip(Size size) => Rect.fromCenter(
      center: Offset(size.width/2,size.height/2),
      width: MediaQuery.of(screenSpace).size.width,
      height: size.height);

  @override
  bool shouldReclip(ClipVertical oldClipper) => oldClipper.screenSpace != screenSpace;
}
