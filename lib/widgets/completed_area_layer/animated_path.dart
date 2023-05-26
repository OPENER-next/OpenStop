import 'dart:ui';

import 'package:flutter/material.dart';


typedef PathBuilder = Path Function(Size size);

class AnimatedPath extends LeafRenderObjectWidget {
  final Animation<double> animation;

  final PathBuilder pathBuilder;

  final double strokeWidth;

  final Color color;

  final PaintingStyle style;

  final StrokeCap strokeCap;

  final StrokeJoin strokeJoin;

  const AnimatedPath({
    required this.animation,
    required this.pathBuilder,
    this.strokeWidth = 5,
    this.color = Colors.red,
    this.style = PaintingStyle.stroke,
    this.strokeCap = StrokeCap.round,
    this.strokeJoin = StrokeJoin.round,
    super.key,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderAnimatedPath(
      animation,
      pathBuilder,
      strokeWidth,
      color,
      style,
      strokeCap,
      strokeJoin,
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderAnimatedPath renderObject) {
    renderObject
    ..animation = animation
    ..pathBuilder = pathBuilder
    ..strokeWidth = strokeWidth
    ..color = color
    ..style = style
    ..strokeCap = strokeCap
    ..strokeJoin = strokeJoin;
  }
}


class RenderAnimatedPath extends RenderBox {
  Animation<double> _animation;

  PathBuilder _pathBuilder;

  final _paint = Paint();

  RenderAnimatedPath(
    this._animation,
    this._pathBuilder,
    double strokeWidth,
    Color color,
    PaintingStyle style,
    StrokeCap strokeCap,
    StrokeJoin strokeJoin,
  ) {
    _animation.addListener(markNeedsPaint);
    _paint
    ..strokeWidth = strokeWidth
    ..color = color
    ..style = style
    ..strokeCap = strokeCap
    ..strokeJoin = strokeJoin;
  }

  PathBuilder get pathBuilder => _pathBuilder;
  set pathBuilder(PathBuilder value) {
    if (value != _pathBuilder) {
      _pathBuilder = value;
      markNeedsPaint();
    }
  }

  Animation<double> get animation => _animation;
  set animation(Animation<double> value) {
    if (value != _animation) {
      _animation.removeListener(markNeedsPaint);
      _animation = value;
      _animation.addListener(markNeedsPaint);
      markNeedsPaint();
    }
  }

  double get strokeWidth => _paint.strokeWidth;
  set strokeWidth(double value) {
    if (value != _paint.strokeWidth) {
      _paint.strokeWidth = value;
      markNeedsPaint();
    }
  }

  Color get color => _paint.color;
  set color(Color value) {
    if (value != _paint.color) {
      _paint.color = value;
      markNeedsPaint();
    }
  }

  PaintingStyle get style => _paint.style;
  set style(PaintingStyle value) {
    if (value != _paint.style) {
      _paint.style = value;
      markNeedsPaint();
    }
  }

  StrokeCap get strokeCap => _paint.strokeCap;
  set strokeCap(StrokeCap value) {
    if (value != _paint.strokeCap) {
      _paint.strokeCap = value;
      markNeedsPaint();
    }
  }

  StrokeJoin get strokeJoin => _paint.strokeJoin;
  set strokeJoin(StrokeJoin value) {
    if (value != _paint.strokeJoin) {
      _paint.strokeJoin = value;
      markNeedsPaint();
    }
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void paint(PaintingContext context, Offset offset) {
    // toList required because metrics can only be iterated once
    final pathMetrics = _pathBuilder(size).computeMetrics().toList();
    final totalLength = pathMetrics.fold<double>(0,
      (prev, metric) => prev + metric.length,
    );

    final currentLength = totalLength * _animation.value;
    final currentPath = _extractPathUntilLength(pathMetrics, currentLength);
    context.canvas.drawPath(currentPath.shift(offset), _paint);
  }

  Path _extractPathUntilLength(Iterable<PathMetric> pathMetrics, double length) {
    var currentLength = 0.0;
    final path = Path();

    for (final metric in pathMetrics) {
      final nextLength = currentLength + metric.length;
      if (nextLength > length) {
        final remainingLength = length - currentLength;
        final pathSegment = metric.extractPath(0.0, remainingLength);
        path.addPath(pathSegment, Offset.zero);
        break;
      }
      else {
        final pathSegment = metric.extractPath(0.0, metric.length);
        path.addPath(pathSegment, Offset.zero);
      }

      currentLength = nextLength;
    }

    return path;
  }

  @override
  void dispose() {
    _animation.removeListener(markNeedsPaint);
    super.dispose();
  }
}
