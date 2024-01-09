import 'package:flutter/material.dart';

class Shimmer extends StatefulWidget {
  final bool active;
  final Color color;
  final Widget child;
  final Duration animationDuration;
  final double min;
  final double max;
  final BlendMode blendMode;

  const Shimmer({
    required this.child, 
    this.active = true,
    this.color = const Color(0xFFF4F4F4),
    this.animationDuration = const Duration(milliseconds: 1500),
    this.min = -1.5,
    this.max = 1.5,
    this.blendMode = BlendMode.color,
    super.key,
  });

  @override 
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this)
    ..repeat(min: widget.min, max: widget.max, period: widget.animationDuration);
  }

  @override
  void didUpdateWidget(covariant Shimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active && oldWidget.active == true) {
      void listener() {
        final totalDuration = _controller.lastElapsedDuration;
        if (totalDuration != null) {
          final double numberRepetition = double.parse(((totalDuration.inMilliseconds / widget.animationDuration.inMilliseconds) + 0.005).toStringAsFixed(3));
          final remainder = numberRepetition % 1; 
          if (remainder == 0) {
            _controller.stop();
            _controller.value = 0.0;
            _controller.removeListener(listener);
            setState(() {});
          }
        }
      }
      _controller.addListener(listener);
    }
      else {
        if (!_controller.isAnimating) {
          _controller.repeat(min: widget.min, max: widget.max, period: widget.animationDuration);
        }
        setState(() {});
      }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  LinearGradient get gradient => LinearGradient(
    colors: [Colors.transparent, widget.color, Colors.transparent,],
    stops: const [ 0.1, 0.3, 0.4,],
    begin: const Alignment(-1.0, -0.3),
    end: const Alignment(1.0, 0.3),
    transform:_SlidingGradientTransform(ratio: _controller.value),
  );
  
  @override
  Widget build(BuildContext context) {
    if (widget.active) {
      return IgnorePointer(
        ignoring: true,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return ShaderMask(
                blendMode: widget.blendMode,
                shaderCallback: gradient.createShader,
                child: widget.child,
            );
          },
        ),
      );
    } 
    else {
      return widget.child;
    }
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.ratio,
  });

  final double ratio;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * ratio, 0.0, 0.0);
  }
}
