import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:newton_particles/newton_particles.dart';

class UploadAnimation extends StatefulWidget {
  final bool active;
  final int particlesEmitRate;
  final int particlesDuration;
  final double particleOverflow;
  final Size particleSize;
  final double particleGap;
  final Offset particleOffset;
  final Color particleColor;
  final int particleLanes;
  final Widget child;

  const UploadAnimation({
    required this.active,
    required this.child,
    this.particlesEmitRate = 200, // Duration between particle emissions in milliseconds
    this.particlesDuration = 4000, // Particle animation duration in milliseconds
    this.particleOverflow = 50, // Heigh size of the area use by the animation
    this.particleGap = 5.0, // Space between particles
    this.particleSize = const Size(50.0, 100.0), // Size of the particle
    this.particleLanes = 1, // Number of effect's columns
    this.particleOffset = Offset.zero, // Shift the initial position of the particle
    this.particleColor = Colors.white,
    super.key,
  });

  @override
  State<UploadAnimation> createState() => _UploadAnimationState();
}

class _UploadAnimationState extends State<UploadAnimation> {
  final _newtonKey = GlobalKey<NewtonState>();
  ui.Image? _image;
  late Effect _effect;

  @override
  void initState() {
    _initializeEffect();
    super.initState();
  }

  void _initializeEffect(){
    _generateImage().then((ui.Image image) {
      setState(() {
        _image = image;
        final effectConfiguration = EffectConfiguration(
          emitDuration: widget.particlesEmitRate,
          minEndScale: 1,
          maxEndScale: 1,
          maxDistance: 200,
          minDuration: widget.particlesDuration,
          maxDuration: widget.particlesDuration,
          minFadeOutThreshold: 0.6,
          maxFadeOutThreshold: 0.8,
        );
        _effect = CustomEffect(
          particleConfiguration: ParticleConfiguration(
            shape: ImageShape(_image!),
            size: widget.particleSize,
            color: SingleParticleColor(color: widget.particleColor),
          ),
          effectConfiguration: effectConfiguration,
          offset: widget.particleOffset,
          lanes: widget.particleLanes,
          particleGap: widget.particleGap,
        );
        _newtonKey.currentState?.clearEffects;
        _newtonKey.currentState?.addEffect(_effect);
        widget.active ? _effect.start() : _effect.stop();
      });
    });
  }

  Future<ui.Image> _generateImage() async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()
      ..color = widget.particleColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    final width = widget.particleSize.width;
    final height = widget.particleSize.height;
    final radius = height / 2;
    final rect = Offset.zero & Size(width.toDouble(), height.toDouble());

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      paint,
    );
    return pictureRecorder.endRecording().toImage(width.toInt(), height.toInt());
  }

  @override
  void didUpdateWidget(covariant UploadAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) {
      widget.active ? _effect.start() : _effect.stop();
    }
    if (widget.particleSize != oldWidget.particleSize){
      _initializeEffect();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Newton(
      key: _newtonKey,
      child: Padding(
        padding: EdgeInsets.only(top: widget.particleOverflow),
        child: widget.child,
      ),
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
