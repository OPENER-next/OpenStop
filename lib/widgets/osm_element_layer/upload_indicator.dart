import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

import '/widgets/animated_path.dart';

class UploadIndicator<T> extends StatefulWidget {
  /// if set will show upload animation
  /// on complete shows finish, on failure fail animation
  final Future<T>? trigger;
  final EdgeInsets padding;
  final Widget child;

  const UploadIndicator({
    required this.trigger,
    required this.child,
    this.padding = EdgeInsets.zero,
    super.key,
  });
  @override
  State<UploadIndicator> createState() => _UploadIndicatorState<T>();
}

class _UploadIndicatorState<T> extends State<UploadIndicator<T>>
    with SingleTickerProviderStateMixin {
  StreamSubscription? _sub;
  bool _succeeded = false;

  late final AnimationController _controller;

  final Duration childOutDuration = const Duration(milliseconds: 300);
  final Duration loadingLoopDuration = const Duration(milliseconds: 1000);
  final Duration finishedInDuration = const Duration(milliseconds: 600);
  final Duration finishedOutDuration = const Duration(milliseconds: 300);
  final Duration childInDuration = const Duration(milliseconds: 600);
  late final totalDuration =
      childOutDuration +
      loadingLoopDuration +
      finishedInDuration +
      finishedOutDuration +
      childInDuration;

  double _durationToDouble(Duration value) => value.inMicroseconds.toDouble();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: totalDuration);
    _subscribe();
    if (widget.trigger != null) {
      _startAnimation();
    }
  }

  void _succeed(T result) {
    _stopAnimation();
    _succeeded = true;
    _unsubscribe();
  }

  void _fail(T error) {
    _stopAnimation();
    _succeeded = false;
    _unsubscribe();
  }

  void _subscribe() {
    // convert to stream to be able to cancel the listener
    _sub = widget.trigger?.asStream().listen(_succeed, onError: _fail);
  }

  void _unsubscribe() {
    _sub?.cancel();
    _sub = null;
  }

  Future<void> _startAnimation() async {
    if (!_controller.isAnimating) {
      final loopStartRatio = _durationToDouble(childOutDuration) / _durationToDouble(totalDuration);
      final loopEndRatio =
          loopStartRatio +
          _durationToDouble(loadingLoopDuration) / _durationToDouble(totalDuration);

      return _controller
          .animateTo(loopStartRatio)
          // bug: initial repeat does not start by given min value instead it adds the min value to the current value and starts then
          // https://github.com/flutter/flutter/issues/67507
          // _RepeatingSimulation is a simplified version of controller.repeat()
          // duration is important, otherwise the total animation controller duration will be used
          .then(
            (value) => _controller.animateWith(
              _RepeatingSimulation(loopStartRatio, loopEndRatio, loadingLoopDuration),
            ),
          );
    }
  }

  Future<void> _stopAnimation() async {
    if (_controller.isAnimating) {
      return _controller.forward().then((value) => _controller.reset());
    }
  }

  @override
  void didUpdateWidget(covariant UploadIndicator<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger) {
      _unsubscribe();
      _subscribe();
      if (widget.trigger != null) {
        _startAnimation();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const shadows = [
      Shadow(
        color: Colors.black12,
        offset: Offset(2, 2),
      ),
    ];
    final child = Padding(
      padding: widget.padding,
      child: FittedBox(child: widget.child),
    );
    if (widget.trigger == null && !_controller.isAnimating) {
      return child;
    }
    return Stack(
      fit: StackFit.passthrough,
      alignment: Alignment.center,
      children: [
        // upload in + loop + out
        SlideTransition(
          position: TweenSequence<Offset>([
            TweenSequenceItem<Offset>(
              tween: ConstantTween(Offset.zero),
              weight: _durationToDouble(childOutDuration),
            ),
            TweenSequenceItem<Offset>(
              tween: Tween<Offset>(
                begin: const Offset(0, 1),
                end: const Offset(0, -1),
              ).chain(CurveTween(curve: Curves.slowMiddle)),
              weight: _durationToDouble(loadingLoopDuration),
            ),
            TweenSequenceItem<Offset>(
              tween: ConstantTween(Offset.zero),
              weight: _durationToDouble(finishedInDuration + finishedOutDuration + childInDuration),
            ),
          ]).animate(_controller),
          child: FadeTransition(
            opacity: TweenSequence<double>([
              TweenSequenceItem<double>(
                tween: ConstantTween(0),
                weight: _durationToDouble(childOutDuration),
              ),
              TweenSequenceItem<double>(
                tween: ConstantTween(1),
                weight: _durationToDouble(loadingLoopDuration),
              ),
              TweenSequenceItem<double>(
                tween: ConstantTween(0),
                weight: _durationToDouble(
                  finishedInDuration + finishedOutDuration + childInDuration,
                ),
              ),
            ]).animate(_controller),
            child: Padding(
              padding: widget.padding,
              child: const FittedBox(
                child: Icon(
                  MdiIcons.arrowUpBold,
                  color: Colors.white,
                  shadows: shadows,
                ),
              ),
            ),
          ),
        ),

        // check mark in + out
        ScaleTransition(
          scale: TweenSequence<double>([
            TweenSequenceItem<double>(
              tween: ConstantTween(1),
              weight: _durationToDouble(
                childOutDuration + loadingLoopDuration + finishedInDuration,
              ),
            ),
            TweenSequenceItem<double>(
              tween: Tween<double>(begin: 1, end: 0).chain(CurveTween(curve: Curves.easeInBack)),
              weight: _durationToDouble(finishedOutDuration),
            ),
            TweenSequenceItem<double>(
              tween: ConstantTween(0),
              weight: _durationToDouble(childInDuration),
            ),
          ]).animate(_controller),
          child: Padding(
            padding: widget.padding,
            child: FittedBox(
              // default size, can be overriden by outer FittedBox
              child: SizedBox(
                width: 30,
                height: 30,
                child: AnimatedPath(
                  animation: TweenSequence<double>([
                    TweenSequenceItem<double>(
                      tween: ConstantTween(0),
                      weight: _durationToDouble(childOutDuration + loadingLoopDuration),
                    ),
                    TweenSequenceItem<double>(
                      tween: Tween<double>(begin: 0, end: 1).chain(CurveTween(curve: Curves.ease)),
                      weight: _durationToDouble(finishedInDuration),
                    ),
                    TweenSequenceItem<double>(
                      tween: ConstantTween(1),
                      weight: _durationToDouble(finishedOutDuration + childInDuration),
                    ),
                  ]).animate(_controller),
                  strokeWidth: 5,
                  color: Colors.white,
                  shadows: shadows,
                  pathBuilder: (size) {
                    if (_succeeded) {
                      return Path()
                        ..moveTo(0.2 * size.width, 0.6 * size.height)
                        ..lineTo(0.45 * size.width, 0.8 * size.height)
                        ..lineTo(0.8 * size.width, 0.3 * size.height);
                    } else {
                      return Path()
                        ..moveTo(0.2 * size.width, 0.2 * size.height)
                        ..lineTo(0.8 * size.width, 0.8 * size.height)
                        ..moveTo(0.8 * size.width, 0.2 * size.height)
                        ..lineTo(0.2 * size.width, 0.8 * size.height);
                    }
                  },
                ),
              ),
            ),
          ),
        ),
        // child out + int
        ScaleTransition(
          scale: TweenSequence<double>([
            TweenSequenceItem<double>(
              tween: Tween<double>(begin: 1, end: 1.2).chain(CurveTween(curve: Curves.ease)),
              weight: _durationToDouble(childOutDuration),
            ),
            TweenSequenceItem<double>(
              tween: ConstantTween(1),
              weight: _durationToDouble(
                loadingLoopDuration + finishedInDuration + finishedOutDuration + childInDuration,
              ),
            ),
          ]).animate(_controller),
          child: FadeTransition(
            opacity: TweenSequence<double>([
              TweenSequenceItem<double>(
                tween: Tween<double>(begin: 1, end: 0).chain(CurveTween(curve: Curves.ease)),
                weight: _durationToDouble(childOutDuration),
              ),
              TweenSequenceItem<double>(
                tween: ConstantTween(0),
                weight: _durationToDouble(
                  loadingLoopDuration + finishedInDuration + finishedOutDuration,
                ),
              ),
              TweenSequenceItem<double>(
                tween: Tween<double>(begin: 0, end: 1).chain(CurveTween(curve: Curves.ease)),
                weight: _durationToDouble(childInDuration),
              ),
            ]).animate(_controller),
            child: child,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _unsubscribe();
    _controller.dispose();
    super.dispose();
  }
}

class _RepeatingSimulation extends Simulation {
  _RepeatingSimulation(this.min, this.max, Duration period)
    : assert(period.inMicroseconds > 0, 'Period should not be 0.'),
      _periodInSeconds = period.inMicroseconds / Duration.microsecondsPerSecond;

  final double min;
  final double max;
  final double _periodInSeconds;

  @override
  double x(double timeInSeconds) {
    final t = (timeInSeconds / _periodInSeconds) % 1.0;
    return lerpDouble(min, max, t)!;
  }

  @override
  double dx(double timeInSeconds) => (max - min) / _periodInSeconds;

  @override
  bool isDone(double timeInSeconds) => false;
}
