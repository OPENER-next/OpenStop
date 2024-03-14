import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:newton_particles/newton_particles.dart';

  class UploadAnimation extends StatefulWidget {
    final bool active;
    final int emitDuration;
    final int particlesPerEmit;
    final double animationHeight;
    final double scaleSize;
    final double padding;
    final double? initialX;
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
      this.initialX,
      this.color = Colors.white,
      super.key,
    });

    @override
    State<UploadAnimation> createState() => _UploadAnimationState();
  }

  class _UploadAnimationState extends State<UploadAnimation> {
    final newtonKey = GlobalKey<NewtonState>();
    EffectConfiguration _effectConfiguration = const EffectConfiguration(
      maxDistance: 200,
      minDuration: 4000,
      maxDuration: 4000,
      minFadeOutThreshold: 0.6,
      maxFadeOutThreshold: 0.8,
    );
    late Effect _effect;
    late Effect _finalEffect;

    @override
    void initState() {
       _effectConfiguration = _effectConfiguration.copyWith(
        emitDuration: widget.emitDuration,
        particlesPerEmit: widget.particlesPerEmit,
        minBeginScale: widget.scaleSize,
        maxBeginScale: widget.scaleSize,
        minEndScale: widget.scaleSize,
        maxEndScale: widget.scaleSize,
      );
      _finalEffect = CustomEffect(
          particleConfiguration: ParticleConfiguration(
            shape: CircleShape(),
            size: Size(widget.scaleSize, widget.scaleSize),
            color: SingleParticleColor(color: widget.color),
          ),
          effectConfiguration: _effectConfiguration,
          initialX: widget.initialX,
          padding: widget.padding,
        );
      _generateImage().then((ui.Image image) {
        _effect = CustomEffect(
          particleConfiguration: ParticleConfiguration(
            shape: ImageShape(image),
            size: Size(widget.scaleSize, widget.scaleSize),
            color: SingleParticleColor(color: widget.color),
          ),
          effectConfiguration: _effectConfiguration,
          initialX: widget.initialX,
          padding: widget.padding
        );
        setState(() {
          _finalEffect = _effect;
          newtonKey.currentState?.addEffect(_finalEffect);
          if (widget.active == true ) {
            _finalEffect.start();
          }
          else {
            _finalEffect.stop();
          }
        });
      });
      super.initState();
    }

    Future<ui.Image> _generateImage() async {
      final pictureRecorder = ui.PictureRecorder();
      final canvas = Canvas(pictureRecorder);
      final painter = PillPainter(color: widget.color);
      painter.paint(canvas, const Size(50, 100));
      final picture = pictureRecorder.endRecording();
      final image = await picture.toImage(50, 100);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List imageData = byteData!.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(imageData);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      return frameInfo.image;
    }

    @override
    void didUpdateWidget(covariant UploadAnimation oldWidget) {
      super.didUpdateWidget(oldWidget);
      if (widget.active != oldWidget.active) {
        setState(() {
          if (widget.active == true) {
            _finalEffect = _effect;
            _finalEffect.start();
          }
          else {
            _finalEffect.stop();
          }
        });
      }
    }

    @override
    Widget build(BuildContext context) {
      return Newton(
        key: newtonKey,
        child: Padding(
          padding: EdgeInsets.only(top: widget.animationHeight),
          child: widget.child
        ),
      );
    }
  }

  class PillPainter extends CustomPainter {
  final Color color;

  PillPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final radius = size.height / 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class CustomEffect extends Effect<AnimatedParticle> {
  double? initialX;
  final double padding;
  final List<double> _xPoints = [];
  var _lastXPosition = 0;
  Size? _surfaceSize;

  CustomEffect({
    required super.particleConfiguration,
    required super.effectConfiguration,
    this.initialX,
    this.padding = 0
  });

  @override
  AnimatedParticle instantiateParticle(Size surfaceSize) {
    final initialPosition = initialX ?? surfaceSize.height;
    if (_xPoints.isEmpty || _surfaceSize != surfaceSize) {
      generateValuesX(surfaceSize);
      _lastXPosition = 0;
    }
    else {
      var generateNumber = true;
      while (generateNumber == true && _xPoints.length > 1) {
          final int generatedNumber = random.nextInt(_xPoints.length);
          if (generatedNumber != _lastXPosition){
            _lastXPosition = generatedNumber;
            generateNumber = false;
          }
      }
    }
    return AnimatedParticle(
      particle: Particle(
        configuration: particleConfiguration,
        position: Offset(
          _xPoints.isEmpty ? padding : _xPoints[_lastXPosition],
          initialPosition,
        ),
      ),
      pathTransformation: StraightPathTransformation(
        distance: initialPosition,
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

  void generateValuesX(Size surface) {
    _xPoints.clear();
    _surfaceSize = surface;
    double initialX = padding;
    final double width = _surfaceSize!.width;
    final double particleWidth = particleConfiguration.size.width * 3;
    final int numberPoints = (width - padding * 2) ~/ particleWidth;

    for (int i = 0; i <= numberPoints; i++) {
      _xPoints.add(initialX);
      initialX += particleWidth;
    }
  }
}
