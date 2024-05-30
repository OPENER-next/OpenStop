import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:newton_particles/newton_particles.dart';

class UploadAnimation extends StatefulWidget {
  final bool active;
  /// Duration between particle emissions in milliseconds
  final int particleEmitRate;
  /// Particle animation duration in milliseconds
  final int particleDuration;
  /// Heigh size of the area use by the animation
  final double particleOverflow;
  /// Size of the particle
  final Size particleSize;
  /// Space between particles
  final double particleGap;
  /// Shift the initial position of the particle
  final Offset particleOffset;
  final Color particleColor;
  /// Number of effect's columns
  final int particleLanes;
  final Widget child;

  const UploadAnimation({
    required this.active,
    required this.child,
    this.particleEmitRate = 200,
    this.particleDuration = 4000,
    this.particleOverflow = 50,
    this.particleGap = 5.0,
    this.particleSize = const Size(8, 16),
    this.particleLanes = 1,
    this.particleOffset = Offset.zero,
    this.particleColor = Colors.white,
    super.key,
  });

  @override
  State<UploadAnimation> createState() => _UploadAnimationState();
}

class _UploadAnimationState extends State<UploadAnimation> {
  ui.Image? _image;
  List<Effect> _effects = [];

  @override
  void initState() {
    _initializeEffect();
    super.initState();
  }

  void _initializeEffect(){
    _createImage().then((ui.Image image) {
      if (_image != null) {
        _image!.dispose();
      }
      if (mounted) {
        setState(() {
          _image = image;
          _effects = [_createEffect(image)];
          _toggleEffect();
        });
      }
    });
  }

  Future<ui.Image> _createImage() async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    final width = widget.particleSize.width.toInt();
    final height = widget.particleSize.height.toInt();
    final radius = height / 2;
    final rect = Offset.zero & widget.particleSize;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      paint,
    );
    return pictureRecorder.endRecording().toImage(width, height);
  }

  CustomEffect _createEffect(ui.Image image) {
    final effectConfiguration = EffectConfiguration(
      emitDuration: widget.particleEmitRate,
      minEndScale: 1,
      maxEndScale: 1,
      maxDistance: 200,
      minDuration: widget.particleDuration,
      maxDuration: widget.particleDuration,
      minFadeOutThreshold: 0,
      maxFadeOutThreshold: 0.8,
    );
    return CustomEffect(
      particleConfiguration: ParticleConfiguration(
        shape: ImageShape(image),
        size: widget.particleSize,
        color: SingleParticleColor(color: widget.particleColor),
      ),
      effectConfiguration: effectConfiguration,
      offset: widget.particleOffset,
      lanes: widget.particleLanes,
      particleGap: widget.particleGap,
    );
  }

  void _toggleEffect() {
    if (widget.active) {
      for (final effect in _effects) {effect.start();}
    }
    else {
      for (final effect in _effects) {effect.stop();}
    }
  }

  @override
  void didUpdateWidget(covariant UploadAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.particleSize != oldWidget.particleSize){
      _initializeEffect();
    }
    else if (
      widget.particleColor != oldWidget.particleColor ||
      widget.particleDuration != oldWidget.particleDuration ||
      widget.particleEmitRate != oldWidget.particleEmitRate ||
      widget.particleGap != oldWidget.particleGap ||
      widget.particleLanes != oldWidget.particleLanes ||
      widget.particleOffset!= oldWidget.particleOffset ||
      widget.particleOverflow != oldWidget.particleOverflow)
    {
      if (_image != null) {
        _effects = [_createEffect(_image!)];
      }
    }
    else if (widget.active != oldWidget.active) {
      _toggleEffect();
    }
  }

  @override
  Widget build(BuildContext context) {
    // stack required because when using Newton via nesting it blocks pointer events
    return Stack(
      children: [
        IgnorePointer(
          child: Newton(
            // important: Newton will only update the effects if we pass in a NEW list
            activeEffects: _effects,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: widget.particleOverflow),
          child: widget.child,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }
}

class CustomEffect extends Effect<AnimatedParticle> {
  final Offset offset;
  final List<int> _lanes;
  final double particleGap;
  int _index = -1;

  CustomEffect({
    required super.particleConfiguration,
    required super.effectConfiguration,
    required this.particleGap,
    required int lanes,
    this.offset = Offset.zero,
  }) : _lanes = List.generate(lanes, (i) => i, growable: false);

  @override
  AnimatedParticle instantiateParticle(Size surfaceSize) {
    // TODO: sometimes surfaceSize is zero causing wrong particles to be emitted
    // probably a newton bug
    return AnimatedParticle(
      particle: _nextParticle(surfaceSize),
      pathTransformation: StraightPathTransformation(
        distance: surfaceSize.height + offset.dy,
        angle: -90,
      ),
      startTime: totalElapsed,
      animationDuration: randomDuration(),
      scaleRange: randomScaleRange(),
      fadeOutThreshold: randomFadeOutThreshold(),
      fadeInLimit: randomFadeInLimit(),
      distanceCurve: effectConfiguration.distanceCurve,
      fadeInCurve: effectConfiguration.fadeInCurve,
      fadeOutCurve: effectConfiguration.fadeOutCurve,
      scaleCurve: effectConfiguration.scaleCurve,
      trail: effectConfiguration.trail,
    );
  }

  Particle _nextParticle(Size surfaceSize) {
    _index++;
    if (_index >= _lanes.length) {
      _index = 0;
      _lanes.shuffle();
    }
    return Particle(
      configuration: particleConfiguration,
      position: _calcParticlePosition(surfaceSize),
    );
  }

  Offset _calcParticlePosition(Size surfaceSize) {
    final particleWidth = particleConfiguration.size.width;
    // total width all lanes including gaps will require
    final particleSpan = _lanes.length * (particleGap + particleWidth) - particleGap;
    // move origin to the bottom left of the centered particleSpan
    final origin = Offset(surfaceSize.width/2 - particleSpan/2 + particleWidth/2, surfaceSize.height);
    // position by lane index times the sum of gap and particle width
    final position = Offset(_lanes[_index] * (particleGap + particleWidth), 0);

    return origin + offset + position;
  }
}
