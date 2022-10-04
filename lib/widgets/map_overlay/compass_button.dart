import 'dart:math';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';

/// The rotation is expected in clockwise radians if not otherwise specified by the [isDegree] parameter.
class CompassButton extends StatelessWidget {
  final double rotation;

  final void Function() onPressed;

  /// Whether the angle unit supplied by the [rotation] is in degrees or radians.
  final bool isDegree;

  static const _piFraction = pi / 180;

  const CompassButton({
    required this.rotation,
    required this.onPressed,
    this.isDegree = false,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: null,
      onPressed: onPressed,
      shape: const CircleBorder(),
      child: Transform.rotate(
        angle: rotation * (isDegree ? _piFraction : 1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CommunityMaterialIcons.triangle,
              color: Colors.red,
              size: 9,
            ),
            Text(
              'N',
              style: TextStyle(
                height: 1.1,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSecondary,
                letterSpacing: 0
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
