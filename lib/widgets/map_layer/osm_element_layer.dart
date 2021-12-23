import 'dart:math';

import 'package:animated_marker_layer/animated_marker_layer.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:osm_api/osm_api.dart';

import '/models/geometric_osm_element.dart';
import '/widgets/map_markers/osm_element_marker.dart';

class OsmElementLayer extends StatefulWidget {
  final Iterable<GeometricOSMElement> geoElements;

  final void Function(OSMElement osmElement)? onOsmElementTap;

  /// The maximum shift in duration between different markers.

  final Duration durationOffsetRange;

  const OsmElementLayer({
    required this.geoElements,
    this.onOsmElementTap,
    this.durationOffsetRange = const Duration(milliseconds: 300),
    Key? key
  }) : super(key: key);

  @override
  State<OsmElementLayer> createState() => _OsmElementLayerState();
}

class _OsmElementLayerState extends State<OsmElementLayer> {
  static Widget _animateInOutBuilder(BuildContext context, Animation<double> animation, Widget child) {
    return Transform.scale(
      scale: animation.value,
      alignment: Alignment.bottomCenter,
      child: child
    );
  }

  final _random = Random();

  late List<AnimatedMarker> _markers;

  @override
  void initState() {
    super.initState();
    _markers = _buildMarkers();
  }

  @override
  void didUpdateWidget(covariant OsmElementLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _markers = _buildMarkers();
  }


  @override
  Widget build(BuildContext context) {
    return AnimatedMarkerLayer(
      markers: _markers,
    );
  }


  List<AnimatedMarker> _buildMarkers() {
    final List<AnimatedMarker> markers = [];
    for (final geoElement in widget.geoElements) {
      markers.add(_buildMarker(geoElement));
    }
    return markers;
  }


  Duration _getRandomDelay() {
    if (widget.durationOffsetRange.inMicroseconds == 0) {
      return Duration.zero;
    }
    final randomTimeOffset = _random.nextInt(widget.durationOffsetRange.inMicroseconds);
    return Duration(microseconds: randomTimeOffset);
  }


  AnimatedMarker _buildMarker(GeometricOSMElement geoElement) {
    return AnimatedMarker(
      key: ValueKey(geoElement.osmElement),
      point: geoElement.geometry.center,
      size: const Size.fromRadius(30),
      anchor: Alignment.bottomCenter,
      animateInBuilder: _animateInOutBuilder,
      animateOutBuilder: _animateInOutBuilder,
      animateInDelay: _getRandomDelay(),
      animateOutDelay: _getRandomDelay(),
      child: OsmElementMarker(
        onTap: () => widget.onOsmElementTap?.call(geoElement.osmElement),
        icon: Icons.ac_unit_rounded
      ),
    );
  }
}
