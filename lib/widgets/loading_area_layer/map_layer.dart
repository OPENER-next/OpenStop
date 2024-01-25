// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';


/// General purpose map layer for rendering multiple widgets using the [MapLayerPositioned] widget.

class MapLayer extends StatelessWidget {
  final List<Widget> children;

  const MapLayer({
    required this.children,
    super.key,
  });

  @override
  Widget build(BuildContext context) => MobileLayerTransformer(
    child: _MapLayer(
      children: children,
    ),
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
    with ContainerRenderObjectMixin<RenderBox, _MapLayerParentData>,
         RenderBoxContainerDefaultsMixin<RenderBox, _MapLayerParentData> {
  RenderMapLayer({
    required MapCamera mapCamera,
    List<RenderBox>? children,
  }) : _mapCamera = mapCamera {
    addAll(children);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _MapLayerParentData) {
      child.parentData = _MapLayerParentData();
    }
  }

  double? _prevZoom;
  LatLng? _prevPos;

  MapCamera get mapCamera => _mapCamera;
  MapCamera _mapCamera;
  set mapCamera(MapCamera value) {
    if (_prevZoom != value.zoom) {
      _prevZoom = value.zoom;
      markNeedsLayout();
    }
    if (_prevPos != value.center) {
      _prevPos = value.center;
      markNeedsPaint();
    }
    if (_mapCamera != value) {
      _mapCamera = value;
    }
  }

  @override
  bool get sizedByParent => true;

  @override
  bool get isRepaintBoundary => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void performLayout() {
    RenderBox? child = firstChild;
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
      final size = _calcSizeFromMeters(childParentData.size!, childParentData.position!, mapCamera.zoom);
      childConstraints = BoxConstraints.tight(size);
    }
    // else use infinite constraints for child
    else {
      childConstraints = const BoxConstraints();
    }

    child.layout(childConstraints, parentUsesSize: true);

    // calculate pixel position of child
    final pxPoint = mapCamera.project(childParentData.position!);
    // shift position to center
    final center = Offset(pxPoint.x.toDouble() - child.size.width/2, pxPoint.y.toDouble() - child.size.height/2);
    // write global pixel offset
    childParentData.offset = center;
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
  bool hitTestChildren(BoxHitTestResult result, { required Offset position }) {
    // transform to global pixel offset
    // because defaultHitTestChildren operates on the offset of the _MapLayerParentData
    // which we set to global pixels on layout
    position = position.translate(
      mapCamera.pixelOrigin.x.toDouble(),
      mapCamera.pixelOrigin.y.toDouble(),
    );
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // transform to local pixel offset
    offset = offset.translate(
      -mapCamera.pixelOrigin.x.toDouble(),
      -mapCamera.pixelOrigin.y.toDouble(),
    );
    // for performance improvements the layer is not clipped
    // instead the whole map widget should be clipped

    // this is an altered version of defaultPaint(context, offset);
    // which does not paint children outside the map layer viewport
    final layerViewport = Rect.fromLTWH(
      mapCamera.pixelOrigin.x.toDouble(),
      mapCamera.pixelOrigin.y.toDouble(),
      mapCamera.size.x,
      mapCamera.size.y,
    );
    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData! as _MapLayerParentData;
      final childRect = child.paintBounds.shift(childParentData.offset);
      // only render child if bounds are inside the viewport
      if (layerViewport.overlaps(childRect)) {
        context.paintChild(child, childParentData.offset + offset);
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

  const MapLayerPositioned({
    required this.position,
    required super.child,
    this.size,
    super.key,
  });

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is _MapLayerParentData);
    final _MapLayerParentData parentData = renderObject.parentData! as _MapLayerParentData;
    assert(renderObject.parent is RenderObject);
    final targetParent = renderObject.parent!;

    if (parentData.size != size) {
      parentData.size = size;
      targetParent.markNeedsLayout();
    }

    if (parentData.position != position) {
      parentData.position = position;
      if (parentData.size != null) {
        // size depends on the geo location, therefore re-layout if size is set in meters
        targetParent.markNeedsLayout();
      }
      else {
        targetParent.markNeedsPaint();
      }
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
}
