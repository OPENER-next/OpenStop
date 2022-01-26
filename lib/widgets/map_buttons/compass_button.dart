import 'dart:math';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';

class CompassButton extends AnimatedWidget {
  /// A function for obtaining the current map rotation.
  /// The rotation is expected in clockwise radians if not otherwise specified by the "isDegree" parameter.
  final double Function() getRotation;

  final void Function() onPressed;

  /// Whether the angle unit supplied by the [getRotation] method is in degrees or radians.
  final bool isDegree;

  static const _piFraction = pi / 180;

  const CompassButton({
    required Listenable listenable,
    required this.getRotation,
    required this.onPressed,
    this.isDegree = false,
    Key? key
  }) : super(listenable: listenable, key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
        heroTag: null,
        onPressed: onPressed,
        shape: const CircleBorder(),
        child: Transform.rotate(
            angle: getRotation() * (isDegree ? _piFraction : 1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CommunityMaterialIcons.navigation,
                  color: Colors.red,
                  size: 13,
                ),
                Text(
                    'N',
                    style: TextStyle(
                        height: 1,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).floatingActionButtonTheme.foregroundColor,
                    )
                ),
              ],
            )
        )
    );
  }
}
