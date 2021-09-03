import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CompassButton extends AnimatedWidget {
  final Listenable listenable;

  /// A function for obtaining the current map rotation.
  /// The rotation is expected in clockwise radians if not otherwise specified by the "isDegree" parameter.
  final double Function() getRotation;

  final void Function() onPressed;

  /// Whether the angle unit supplied by the [getRotation] method is in degrees or radians.
  final bool isDegree;

  static const _piFraction = pi / 180;

  const CompassButton({
    required this.listenable,
    required this.getRotation,
    required this.onPressed,
    this.isDegree = false
  }) : super(listenable: listenable);

  Widget build(BuildContext context) {
    return FloatingActionButton(
      mini: true,
      onPressed: onPressed,
        child: Transform.rotate(
        angle: getRotation() * (isDegree ? _piFraction : 1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.arrowtriangle_up_fill,
              color: Colors.red,
              size: 12,
            ),
            Text(
              'N',
              style: TextStyle(
                height: 1,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black
              )
            ),
          ],
        )
      )
    );
  }
}
