import 'dart:math';

import 'package:animated_marker_layer/animated_marker_layer.dart';
import 'package:flutter/material.dart';

import '/models/stop_area.dart';
import '/widgets/map_markers/stop_area_indicator.dart';

class StopAreaLayer extends StatefulWidget {
  final Iterable<StopArea> stopAreas;

  final Iterable<StopArea> loadingStopAreas;

  final double sizeThreshold;

  final void Function(StopArea stopArea)? onStopAreaTap;

  const StopAreaLayer({
    required this.stopAreas,
    required this.loadingStopAreas,
    this.onStopAreaTap,
    // TODO: reimplement this in the AnimatedMarkerLayer
    this.sizeThreshold = 5,
    Key? key,
  }) : super(key: key);

  @override
  State<StopAreaLayer> createState() => _StopAreaLayerState();
}


class _StopAreaLayerState extends State<StopAreaLayer> {
  final _random = Random();

  late List<AnimatedMarker> _markers = _buildMarkers();


  @override
  void didUpdateWidget(covariant StopAreaLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _markers = _buildMarkers();
  }


  List<AnimatedMarker> _buildMarkers() {
    final markers = <AnimatedMarker>[];
    for (final stopArea in widget.stopAreas) {
      markers.add(_createMarker(
        stopArea,
        isLoading: widget.loadingStopAreas.contains(stopArea)
      ));
    }
    return markers;
  }


  @override
  Widget build(BuildContext context) {
    return AnimatedMarkerLayer(
      markers: _markers,
    );
  }


  AnimatedMarker _createMarker(StopArea stopArea, { required bool isLoading }) {
    return AnimatedMarker(
      animateInBuilder: _animateInOutBuilder,
      animateOutBuilder: _animateInOutBuilder,
      animateInCurve: Curves.ease,
      animateOutCurve: Curves.ease,
      animateInDelay: _getRandomDelay(),
      animateOutDelay: _getRandomDelay(),
      // create unique key
      // this needs to be done so flutter can re-identify the correct element
      key: ValueKey(stopArea),
      size: Size.square(stopArea.diameter),
      sizeUnit: SizeUnit.meters,
      point: stopArea.center,
      child: StopAreaIndicator(
        isLoading: isLoading,
        onTap: () => widget.onStopAreaTap?.call(stopArea),
      )
    );
  }


  Widget _animateInOutBuilder(BuildContext context, Animation<double> animation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }


  Duration _getRandomDelay() {
    final randomTimeOffset = _random.nextInt(300);
    return Duration(milliseconds: randomTimeOffset);
  }
}
