
import 'package:flutter/material.dart';

class Shimmer extends StatefulWidget {
  final bool active;
  final Color color;
  final Widget? child;
  final Duration animationDuration;
  final Duration animationDelay;
  final double min;
  final double max;
  final BlendMode blendMode;

  const Shimmer({
    this.child, 
    this.active = true,
    this.color = const Color(0xFFF4F4F4),
    this.animationDuration = const Duration(milliseconds: 1500),
    this.animationDelay = const Duration(milliseconds: 50),
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
  late final Animation<double> ratio;
  late final Duration totalDuration; 
  
  @override
  void initState() {
    super.initState();
    totalDuration = widget.animationDuration + widget.animationDelay;
    final begin = widget.min - ((widget.animationDelay.inMilliseconds * (widget.max - widget.min))/ totalDuration.inMilliseconds);
    _controller = AnimationController(
      vsync: this,
      duration: totalDuration,
    );
    ratio = _controller.drive(Tween<double>(begin: begin, end: widget.max));
  }

  @override
  void didUpdateWidget(covariant Shimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) {
      if (oldWidget.active == true) {
        _controller.forward(from: _controller.value).whenComplete(()
          {
            _controller.stop();
            setState(() {});
          }
        );
      }
      else { _controller.repeat();}
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  LinearGradient get gradient => LinearGradient(
    colors: [ widget.color.withOpacity(0.0), widget.color, widget.color.withOpacity(0.0),],
    stops: const [ 0.1, 0.3, 0.4,],
    begin: const Alignment(-1.0, -0.3),
    end: const Alignment(1.0, 0.3),
    transform:_SlidingGradientTransform(ratio: ratio.value),
  );
  
  @override
  Widget build(BuildContext context) {
    if (_controller.isAnimating) {
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
      return const SizedBox();
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
