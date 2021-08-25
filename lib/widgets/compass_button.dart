import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';


class CompassButton extends AnimatedWidget {
  final MapboxMapController controller;
  final double size;
  final void Function() onPressed;

  final piFraction = pi / 180;

  CompassButton({
    required this.controller,
    required this.onPressed,
    required this.size,
  }) : super(listenable: controller);

  Widget build(BuildContext context) {
    return FloatingActionButton(
      mini: true,
      backgroundColor: Theme.of(context).accentColor,
      onPressed: onPressed,
      child: SizedBox(
        width: size,
        height: size,
        child: Transform.rotate(
          angle: -piFraction * (controller.cameraPosition?.bearing ?? 1),
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Positioned(
                bottom: -(size*0.1),
                child: Text('N',
                    style: TextStyle(
                        fontSize: size*0.6,
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                    )
                ),
              ),
              Positioned(
                top: -(size*0.1),
                child: Icon(
                    CupertinoIcons.arrowtriangle_up_fill,
                    color: Colors.red,
                    size: size*0.6,
                    ),
                ),
            ],
          )
        )
      ),
    );
  }
}
