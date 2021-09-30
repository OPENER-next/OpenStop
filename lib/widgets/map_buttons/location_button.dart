
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

    // set initial animation state
    if (widget.cameraTracker.state == CameraTrackerState.active) {
      _animationController.value = _animationController.upperBound;
    }

    widget.cameraTracker.addListener(() {
      if (widget.cameraTracker.state == CameraTrackerState.active) {
        _animationController.forward();
      }
      else if (widget.cameraTracker.state == CameraTrackerState.inactive) {
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
    if (widget.cameraTracker.state == CameraTrackerState.inactive) {
      widget.cameraTracker.startTacking();
    }
    else if (widget.cameraTracker.state == CameraTrackerState.active) {
      widget.cameraTracker.stopTracking();
    }
  }


  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }
}