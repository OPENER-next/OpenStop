import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import '/commons/geo_utils.dart';


class ScaledMarkerLayerOptions extends LayerOptions {
  final List<ScaledMarker> markers;

  /// The pixel size at which markers will be hidden.
  final double sizeThreshold;

  ScaledMarkerLayerOptions({
    Key? key,
    this.markers = const [],
    this.sizeThreshold = 5,
    Stream<Null>? rebuild,
  }) : super(key: key, rebuild: rebuild);
}


class ScaledMarker {
  final LatLng point;
  final Widget child;
  final Key? key;
  final double size;

  ScaledMarker({
    required this.point,
    required this.child,
    this.key,
    this.size = 30.0,
  });
}


class ScaledMarkerLayerWidget extends StatelessWidget {
  final ScaledMarkerLayerOptions options;

  ScaledMarkerLayerWidget({Key? key, required this.options}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mapState = MapState.maybeOf(context)!;
    return ScaledMarkerLayer(options, mapState, mapState.onMoved);
  }
}


class ScaledMarkerLayer extends StatefulWidget {
  final ScaledMarkerLayerOptions markerLayerOptions;
  final MapState map;
  final Stream<Null>? stream;

  ScaledMarkerLayer(this.markerLayerOptions, this.map, this.stream)
      : super(key: markerLayerOptions.key);

  @override
  _ScaledMarkerLayerState createState() => _ScaledMarkerLayerState();
}

class _ScaledMarkerLayerState extends State<ScaledMarkerLayer> {
  var lastZoom = -1.0;

  var _pxCache = <CustomPoint>[];

  // Calling this every time markerOpts change should guarantee proper length
  List<CustomPoint> generatePxCache() => List.generate(
        widget.markerLayerOptions.markers.length,
        (i) => widget.map.project(widget.markerLayerOptions.markers[i].point),
      );

  @override
  void initState() {
    super.initState();
    _pxCache = generatePxCache();
  }

  @override
  void didUpdateWidget(covariant ScaledMarkerLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    lastZoom = -1.0;
    _pxCache = generatePxCache();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int?>(
      stream: widget.stream, // a Stream<int> or null
      builder: (BuildContext context, AsyncSnapshot<int?> snapshot) {

        final markers = <Widget>[];
        final sameZoom = widget.map.zoom == lastZoom;

        for (var i = 0; i < widget.markerLayerOptions.markers.length; i++) {
          final marker = widget.markerLayerOptions.markers[i];

          // Decide whether to use cached point or calculate it
          final pxPoint =
              sameZoom ? _pxCache[i] : widget.map.project(marker.point);
          if (!sameZoom) {
            _pxCache[i] = pxPoint;
          }

          final size = pixelValue(marker.point.latitude, marker.size, widget.map.zoom);
          final shift = size - size/2;

          final sw = CustomPoint(pxPoint.x + shift, pxPoint.y - shift);
          final ne = CustomPoint(pxPoint.x - shift, pxPoint.y + shift);

          if (!widget.map.pixelBounds.containsPartialBounds(Bounds(sw, ne)) ||
              size < widget.markerLayerOptions.sizeThreshold
          ) {
            continue;
          }

          final pos = pxPoint - widget.map.getPixelOrigin();

          markers.add(
            Positioned(
              key: marker.key,
              width: size,
              height: size,
              left: pos.x - shift,
              top: pos.y - shift,
              child: marker.child,
            ),
          );
        }

        lastZoom = widget.map.zoom;

        return Stack(
          children: markers,
        );
      },
    );
  }
}