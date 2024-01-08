import 'package:flutter/material.dart';

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.slidePercent,
  });

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

class Shimmer extends StatefulWidget {
  final bool isLoading;
  final Widget child;

  const Shimmer({
    required this.isLoading,
    required this.child, 
    Key? key,
  }) : super(key: key);

  @override
  _ShimmerState createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer>
  with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  LinearGradient get gradient => LinearGradient(
    colors: [Colors.transparent, Theme.of(context).colorScheme.primary.withOpacity(0.7) , Colors.transparent,],
    stops: const [ 0.1, 0.3, 0.4,],
    begin: const Alignment(-1.0, -0.3),
    end: const Alignment(1.0, 0.3),
    transform:
          _SlidingGradientTransform(slidePercent: _controller.value),
  );
  
  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return ShaderMask(
              blendMode: BlendMode.color,
              shaderCallback: (Rect bounds) {
                return gradient.createShader(bounds);
              },
              child: widget.child,
          );
        },
      );
    } else {
      return const SizedBox();
    }
  }
}
