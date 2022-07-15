import 'dart:math';

import 'package:animated_marker_layer/animated_marker_layer.dart';
import 'package:flutter/material.dart';

import '/models/stop_area.dart';
import '/widgets/stop_area_layer/stop_area_indicator.dart';

class StopAreaLayer extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return AnimatedMarkerLayer(
      markers: stopAreas.map((stopArea) => _StopAreaMarker(
        stopArea: stopArea,
        isLoading: loadingStopAreas.contains(stopArea),
        builder: _markerBuilder,
      )).toList()
    );
  }

  Widget _markerBuilder(BuildContext context, Animation<double> animation, AnimatedMarker marker) {
    marker as _StopAreaMarker;

    return FadeTransition(
      opacity: animation,
      child: StopAreaIndicator(
        isLoading: marker.isLoading,
        onTap: () => onStopAreaTap?.call(marker.stopArea),
      ),
    );
  }
}


class _StopAreaMarker extends AnimatedMarker {
  final bool isLoading;
  final StopArea stopArea;

  _StopAreaMarker({
    required this.stopArea,
    required this.isLoading,
    required super.builder
  }) : super(
    key: ValueKey(stopArea),
    point: stopArea.center,
    size: Size.square(stopArea.diameter),
    sizeUnit: SizeUnit.meters,
    animateInCurve: Curves.ease,
    animateOutCurve: Curves.ease,
    animateInDelay: _getRandomDelay,
    animateOutDelay: _getRandomDelay
  );

  static final _random = Random();

  static Duration get _getRandomDelay => Duration(
    milliseconds: _random.nextInt(300)
  );
}
