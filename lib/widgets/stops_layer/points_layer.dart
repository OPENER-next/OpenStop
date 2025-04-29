import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
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
    final mapCamera = MapCamera.of(context);

    return RenderPointsLayer(
      Float32List.fromList(
        _localPoints(mapCamera).toList(growable: false),
      ),
      radius * 2,
      color,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderPointsLayer renderObject) {
    // watch map changes
    final mapCamera = MapCamera.of(context);

    renderObject.points = Float32List.fromList(
      _localPoints(mapCamera).toList(growable: false),
    );
    renderObject.diameter = radius * 2;
    renderObject.color = color;
  }

  Iterable<double> _localPoints(MapCamera mapCamera) sync* {
    final relativePixelCenter = mapCamera.nonRotatedSize.center(Offset.zero);
    final unrotatedPixelOrigin = mapCamera.projectAtZoom(mapCamera.center) - relativePixelCenter;

    for (final point in points) {
      final pxPoint = mapCamera.projectAtZoom(point);
      final bounds = Rect.fromCircle(center: pxPoint, radius: radius.toDouble());
      final isVisible = mapCamera.pixelBounds.overlaps(bounds);

      if (isVisible) {
        final relativePos = pxPoint - unrotatedPixelOrigin;
        final pos = mapCamera.rotatePoint(relativePixelCenter, relativePos, counterRotation: false);
        yield pos.dx;
        yield pos.dy;
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

  double get diameter => _paint.strokeWidth;
  set diameter(double value) {
    if (_paint.strokeWidth != value) {
      _paint.strokeWidth = value;
      markNeedsPaint();
    }
  }

  Color get color => _paint.color;
  set color(Color value) {
    if (_paint.color != value) {
      _paint.color = value;
      markNeedsPaint();
    }
  }

  Float32List get points => _points;
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
    context.pushTransform(false, offset, Matrix4.identity(), (context, _) {
      context.canvas.drawRawPoints(PointMode.points, _points, _paint);
    });
  }
}
