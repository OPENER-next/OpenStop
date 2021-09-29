
import 'package:flutter/material.dart';
import '/helpers/camera_tracker.dart';

class LocationButton extends StatefulWidget {
  final CameraTracker cameraTracker;

  LocationButton({
    required this.cameraTracker,
  });

  @override
  State<LocationButton> createState() => _LocationButtonState();
}

class _LocationButtonState extends State<LocationButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 300)
  );

  late final _colorTweenAnimation = ColorTween(
    begin: Colors.black,
    end: Colors.white
  ).animate(_animationController);

  late final _backgroundColorTweenAnimation = ColorTween(
    begin: Colors.white,
    end: Theme.of(context).colorScheme.primary
  ).animate(_animationController);


  @override
  initState() {
    super.initState();

    widget.cameraTracker.addListener(() {
      if (widget.cameraTracker.isActive) {
        _animationController.forward();
      }
      else {
        _animationController.reverse();
      }
    });
  }


  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorTweenAnimation,
      builder: (context, child) => FloatingActionButton.small(
        backgroundColor: _backgroundColorTweenAnimation.value,
        child: Icon(
          Icons.my_location,
          color: _colorTweenAnimation.value,
        ),
        onPressed: _handleButtonPress
      )
    );
  }


  _handleButtonPress() {
    if (!widget.cameraTracker.isActive) {
      widget.cameraTracker.startTacking();
    }
    else {
      widget.cameraTracker.stopTracking();
    }
  }


  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }
}