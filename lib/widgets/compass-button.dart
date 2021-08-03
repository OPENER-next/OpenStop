import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';


class CompassButton extends AnimatedWidget {
  final MapboxMapController controller;
  final ButtonStyle style;
  final double size;
  final void Function() onPressed;

  final piFraction = pi / 180;

  CompassButton({
    required this.controller,
    required this.onPressed,
    required this.style,
    this.size = 25.0
  }) : super(listenable: controller);

  Widget build(BuildContext context) {
    return ElevatedButton(
      style: style,
      onPressed: onPressed,
      child: Transform.rotate(
        angle: -piFraction * (controller.cameraPosition?.bearing ?? 1),
        child: SizedBox(
          height: size,
          width: size,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('▲', style: TextStyle(
                height: size * 0.037,
                color: Colors.red
              )),
              Text('N', style: TextStyle(
                height: size * 0.035,
                fontWeight: FontWeight.bold,
                color: Colors.black
              )),
            ],
          )
        )
      ),
    );
  }
}
