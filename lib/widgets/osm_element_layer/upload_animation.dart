import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:newton_particles/newton_particles.dart';

class UploadAnimation extends StatefulWidget {
  final bool active;
  final int emitDuration;
  final int particlesPerEmit;
  final double animationHeight;
  final double scaleSize;
  final double padding;
  final double initialX;
  final Color color;
  final Widget child;

  const UploadAnimation({
    required this.active,
    required this.child,
    this.emitDuration = 200,
    this.particlesPerEmit = 1,
    this.animationHeight = 50,
    this.scaleSize = 3.0,
    this.padding = 0,
    this.initialX = 0,
    this.color = Colors.white,
    super.key,
  });

  @override
  State<UploadAnimation> createState() => _UploadAnimationState();
}

class _UploadAnimationState extends State<UploadAnimation> {
  final _newtonKey = GlobalKey<NewtonState>();
  late Effect _effect;

  @override
  void initState() {
    super.initState();

    _generateImage().then((ui.Image image) {
      setState(() {
        final effectConfiguration = EffectConfiguration(
          emitDuration: widget.emitDuration,
          particlesPerEmit: widget.particlesPerEmit,
          minBeginScale: widget.scaleSize,
          maxBeginScale: widget.scaleSize,
          minEndScale: widget.scaleSize,
          maxEndScale: widget.scaleSize,
          maxDistance: 200,
          minDuration: 4000,
          maxDuration: 4000,
          minFadeOutThreshold: 0.6,
          maxFadeOutThreshold: 0.8,
        );

        _effect = CustomEffect(
          particleConfiguration: ParticleConfiguration(
            shape: ImageShape(image),
            size: Size(widget.scaleSize, widget.scaleSize),
            color: SingleParticleColor(color: widget.color),
          ),
          effectConfiguration: effectConfiguration,
          offset: Offset(0, widget.initialX),
          lanes: 4
        );

        _newtonKey.currentState?.addEffect(_effect);
        widget.active ? _effect.start() : _effect.stop();
      });
    });
  }

  Future<ui.Image> _generateImage() async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()
      ..color = widget.color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    const width = 50;
    const height = 100;
    const radius = height / 2;
    final rect = Offset.zero & Size(width.toDouble(), height.toDouble());

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(radius)),
      paint,
    );
    return pictureRecorder.endRecording().toImage(width, height);
  }

  @override
  void didUpdateWidget(covariant UploadAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) {
      widget.active ? _effect.start() : _effect.stop();
    }
    // TODO make checks for other properties and update _effect accordingly
    // if () {

    // }
  }

  @override
  Widget build(BuildContext context) {
    return Newton(
      key: _newtonKey,
      child: Padding(
        padding: EdgeInsets.only(top: widget.animationHeight),
        child: widget.child,
      ),
    );
  }
}

class CustomEffect extends Effect<AnimatedParticle> {
  final Offset offset;
  final List<int> _lanes;
  int _index = -1;

  CustomEffect({
    required super.particleConfiguration,
    required super.effectConfiguration,
    required int lanes,
    this.offset = Offset.zero,
  }) : _lanes = List.generate(lanes, (i) => i, growable: false);

  @override
  AnimatedParticle instantiateParticle(Size surfaceSize) {
    return AnimatedParticle(
      particle: _nextParticle(surfaceSize),
      pathTransformation: StraightPathTransformation(
        distance: surfaceSize.height,
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
    final particleGap = 10;
    // total width all lanes including gaps will require
    final particleSpan = _lanes.length * (particleGap + particleWidth) - particleGap;
    // move origin to the bottom left of the centered particleSpan
    final origin = Offset(surfaceSize.width/2 - particleSpan/2 + particleWidth/2, surfaceSize.height);
    // position by lane index times the sum of gap and particle width
    final position = Offset(_lanes[_index] * (particleGap + particleWidth), 0);
    return origin + offset + position;
  }
}
