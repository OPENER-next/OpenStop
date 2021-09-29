import 'dart:math';
import 'package:flutter/material.dart';

class StopAreaIndicator extends StatefulWidget {
  final double size;

  final Duration duration;

  StopAreaIndicator({
    this.size = 100,
    this.duration = const Duration(seconds: 2)
  });

  @override
  State<StopAreaIndicator> createState() => _StopAreaIndicatorState();
}

class _StopAreaIndicatorState extends State<StopAreaIndicator> with TickerProviderStateMixin {
  final DecorationTween decorationTween = DecorationTween(
    begin: BoxDecoration(
      shape: BoxShape.circle,
      gradient: SweepGradient(
        startAngle: -pi/1.3,
        endAngle: 0,
        colors: <Color>[
          Colors.greenAccent.withOpacity(0),
          Colors.greenAccent.withOpacity(0.75)
        ],
        tileMode: TileMode.decal,
        transform: GradientRotation(1)
      )
    ),
    end: BoxDecoration(
      shape: BoxShape.circle,
      gradient: SweepGradient(
        tileMode: TileMode.decal,
        startAngle: pi*2,
        endAngle: pi*2,
        colors: <Color>[
          Colors.greenAccent.withOpacity(0),
          Colors.greenAccent.withOpacity(0.75)
        ],
        transform: GradientRotation(3)
      )
    ),
  );

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();


  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBoxTransition(
        //position: DecorationPosition.foreground,
        decoration: decorationTween.animate(_controller),
        child: Container(
          decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.2), shape: BoxShape.circle),
          width: widget.size,
          height: widget.size,
        ),
      )
    );
  }



  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

