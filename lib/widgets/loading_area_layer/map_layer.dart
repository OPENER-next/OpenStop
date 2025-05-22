import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// General purpose map layer for rendering multiple widgets using the [MapLayerPositioned] widget.

class MapLayer extends StatelessWidget {
  final List<Widget> children;

  const MapLayer({
    required this.children,
    super.key,
  });

  @override
  Widget build(BuildContext context) => _MapLayer(
    children: children,
  );
}

class _MapLayer extends MultiChildRenderObjectWidget {
  const _MapLayer({
    super.children,
  });

  @override
  RenderMapLayer createRenderObject(BuildContext context) => RenderMapLayer(
    mapCamera: MapCamera.of(context),
  );

  @override
  void updateRenderObject(BuildContext context, covariant RenderMapLayer renderObject) {
    renderObject.mapCamera = MapCamera.of(context);
  }
}

class RenderMapLayer extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _MapLayerParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _MapLayerParentData> {
  RenderMapLayer({
    required MapCamera mapCamera,
    List<RenderBox>? children,
  }) : _mapCamera = mapCamera {
    addAll(children);
    _updateCachedValues();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _MapLayerParentData) {
      child.parentData = _MapLayerParentData();
    }
  }

  /// projected camera position
  late Offset _pixelMapCenter;

  /// top left position of the camera in pixels
  late Offset _nonRotatedPixelOrigin;

  void _updateCachedValues() {
    _pixelMapCenter = mapCamera.projectAtZoom(mapCamera.center);
    _nonRotatedPixelOrigin = _pixelMapCenter - mapCamera.nonRotatedSize.center(Offset.zero);
  }

  MapCamera get mapCamera => _mapCamera;
  MapCamera _mapCamera;
  set mapCamera(MapCamera value) {
    if (_mapCamera.zoom != value.zoom) {
      markNeedsLayout();
    }
    if (_mapCamera.center != value.center || _mapCamera.rotation != value.rotation) {
      markNeedsPaint();
    }
    _mapCamera = value;
    _updateCachedValues();
  }

  @override
  bool get sizedByParent => true;

  @override
  bool get isRepaintBoundary => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void performLayout() {
    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as _MapLayerParentData;
      _layoutChild(child);
      child = childParentData.nextSibling;
    }
  }

  void _layoutChild(RenderBox child) {
    final childParentData = child.parentData! as _MapLayerParentData;
    final BoxConstraints childConstraints;

    // if size in meters is specified
    if (childParentData.size != null && childParentData.position != null) {
      // calc tight size constraints
      final size = _calcSizeFromMeters(
        childParentData.size!,
        childParentData.position!,
        mapCamera.zoom,
      );
      childConstraints = BoxConstraints.tight(size);
    }
    // else use infinite constraints for child
    else {
      childConstraints = const BoxConstraints();
    }
    child.layout(childConstraints, parentUsesSize: true);

    // calculate pixel position of child
    final pxPoint = mapCamera.projectAtZoom(childParentData.position!);
    // write global pixel offset
    childParentData.offset = pxPoint;
  }

  /// Computes the position for the global pixel coordinate system.

  Offset _computeAbsoluteChildPosition(RenderBox child) {
    final childParentData = child.parentData! as _MapLayerParentData;
    var globalPixelPosition = childParentData.offset;
    // apply rotation
    if (mapCamera.rotation != 0.0) {
      globalPixelPosition = mapCamera.rotatePoint(
        _pixelMapCenter,
        childParentData.offset,
        counterRotation: false,
      );
    }
    // apply alignment
    return globalPixelPosition - childParentData.align!.alongSize(child.size);
  }

  /// Computes the position relative to the map camera.

  Offset _computeRelativeChildPosition(RenderBox child) {
    return _computeAbsoluteChildPosition(child) - _nonRotatedPixelOrigin;
  }

  // earth circumference in meters
  static const _earthCircumference = 2 * pi * earthRadius;

  static const _piFraction = pi / 180;

  double _metersPerPixel(double latitude, double zoomLevel) {
    final latitudeRadians = latitude * _piFraction;
    return _earthCircumference * cos(latitudeRadians) / pow(2, zoomLevel + 8);
  }

  Size _calcSizeFromMeters(Size size, LatLng point, double zoom) {
    return size / _metersPerPixel(point.latitude, zoom);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    // this is an altered version of the defaultHitTestChildren method
    // because the position/offset stored in the parentData is not local/relative
    var child = lastChild;
    while (child != null) {
      final offset = _computeRelativeChildPosition(child);
      final childParentData = child.parentData! as _MapLayerParentData;
      final isHit = result.addWithPaintOffset(
        offset: offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          return child!.hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        return true;
      }
      child = childParentData.previousSibling;
    }
    return false;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // for performance improvements the layer is not clipped
    // instead the whole map widget should be clipped
    // this is an altered version of defaultPaint(context, offset);
    // which does not paint children outside the map layer viewport

    final viewport = Offset.zero & mapCamera.nonRotatedSize;

    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as _MapLayerParentData;
      final relativePixelPosition = _computeRelativeChildPosition(child);
      final childRect = relativePixelPosition & child.size;
      // only render child if bounds are inside the viewport
      if (viewport.overlaps(childRect)) {
        context.paintChild(child, relativePixelPosition + offset);
      }
      child = childParentData.nextSibling;
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('mapCamera', mapCamera));
  }
}

/// Widget to position other [Widget]s on a [MapLayer].
///
/// The parent [MapLayer] widget will handle the positioning.
///
/// The [size] property specifies the widgets dimensions in meters. This means the widget size changes on zoom.
///
/// If [size] is omitted the intrinsic size of [child] will be used. This means the size will **not** change on zoom.

class MapLayerPositioned extends ParentDataWidget<_MapLayerParentData> {
  final LatLng position;

  final Size? size;

  final Alignment align;

  const MapLayerPositioned({
    required this.position,
    required super.child,
    this.align = Alignment.center,
    this.size,
    super.key,
  });

  @override
  void applyParentData(RenderObject renderObject) {
    assert(
      renderObject.parentData is _MapLayerParentData,
      'RenderObject parentData is not of type _MapLayerParentData',
    );
    final parentData = renderObject.parentData! as _MapLayerParentData;
    assert(renderObject.parent is RenderObject, 'RenderObject parent is not of type RenderObject');
    final targetParent = renderObject.parent!;

    if (parentData.size != size) {
      parentData.size = size;
      targetParent.markNeedsLayout();
    }

    if (parentData.position != position) {
      parentData.position = position;
      // if size is set in meters it depends on the geo location, therefore re-layout is necessary
      // TODO: also currently the projection is done on layout so if the position changes we need to re-project
      targetParent.markNeedsLayout();
    }

    if (parentData.align != align) {
      parentData.align = align;
      targetParent.markNeedsPaint();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => MapLayer;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('position', position));
    properties.add(DiagnosticsProperty('size', size));
  }
}

class _MapLayerParentData extends ContainerBoxParentData<RenderBox> {
  LatLng? position;

  Size? size;

  Alignment? align;
}
