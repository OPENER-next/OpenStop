import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';


/// A fast point drawing layer.
/// As a drawback all points have to be of the same size and color.

class PointsLayer extends LeafRenderObjectWidget  {

  final Iterable<LatLng> points;

  final num radius;

  final Color color;

  const PointsLayer({
    required this.points,
    this.radius = 5,
    this.color = Colors.blueAccent,
    super.key,
  });

  @override
  RenderPointsLayer createRenderObject(BuildContext context) {
    // watch map changes
    final map = FlutterMapState.maybeOf(context)!;

    return RenderPointsLayer(
      Float32List.fromList(
        _localPoints(map).toList(growable: false),
      ),
      radius * 2,
      color,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderPointsLayer renderObject) {
    // watch map changes
    final map = FlutterMapState.maybeOf(context)!;

    renderObject.points = Float32List.fromList(
      _localPoints(map).toList(growable: false),
    );
    renderObject.diameter = radius * 2;
    renderObject.color = color;
  }

  Iterable<double> _localPoints(FlutterMapState map) sync* {
    for (final point in points) {
      final pxPoint = map.project(point);

      final sw = CustomPoint(pxPoint.x + radius, pxPoint.y + radius);
      final ne = CustomPoint(pxPoint.x - radius, pxPoint.y - radius);

      final isVisible = map.pixelBounds.containsPartialBounds(Bounds(sw, ne));

      if (isVisible) {
        final pos = pxPoint - map.pixelOrigin;
        yield pos.x.toDouble();
        yield pos.y.toDouble();
      }
    }
  }
}


class RenderPointsLayer extends RenderBox {

  final Paint _paint;

  Float32List _points;

  RenderPointsLayer(
    Float32List points,
    double diameter,
    Color color,
  ) : _paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = diameter
      ..color = color,
      _points = points;

  set diameter(double value) {
    if (_paint.strokeWidth != value) {
      _paint.strokeWidth = value;
      markNeedsPaint();
    }
  }

  set color(Color value) {
    if (_paint.color != value) {
      _paint.color = value;
      markNeedsPaint();
    }
  }

  set points(Float32List value) {
    _points = value;
    markNeedsPaint();
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  // disable any hit tests
  @override
  bool hitTestSelf(Offset position) => false;

  @override
  void paint(PaintingContext context, Offset offset) {
    // required for rotation
    context.pushTransform(false, Offset.zero, Matrix4.translationValues(offset.dx, offset.dy, 0), (context, _) {
      context.canvas.drawRawPoints(PointMode.points, _points, _paint);
    });
  }
}
