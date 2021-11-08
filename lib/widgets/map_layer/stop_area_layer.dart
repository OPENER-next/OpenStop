import 'package:animated_marker_layer/animated_marker_layer.dart';
import 'package:flutter/material.dart';
import '/models/stop_area.dart';
import '/widgets/map_markers/stop_area_indicator.dart';

class StopAreaLayer extends StatefulWidget {
  final Iterable<StopArea> stopAreas;

  final Iterable<StopArea> loadingStopAreas;

  final double stopAreaDiameter;

  final double sizeThreshold;

  final void Function(StopArea stopArea)? onStopAreaTap;

  const StopAreaLayer({
    required this.stopAreas,
    required this.loadingStopAreas,
    this.onStopAreaTap,
    this.stopAreaDiameter = 100,
    // TODO: reimplement this in the AnimatedMarkerLayer
    this.sizeThreshold = 5
  });

  @override
  State<StopAreaLayer> createState() => _StopAreaLayerState();
}


class _StopAreaLayerState extends State<StopAreaLayer> {
  late List<AnimatedMarker> _markers;

  @override
  void initState() {
    super.initState();
    _markers = _buildMarkers();
  }


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
      // create unique key based on location
      // this needs to be done so flutter can re-identify the correct element
      key: ValueKey(stopArea.center),
      size: Size.square(stopArea.diameter + widget.stopAreaDiameter),
      sizeUnit: SizeUnit.meters,
      point: stopArea.center,
      child: StopAreaIndicator(
        isLoading: isLoading,
        onTap: () => widget.onStopAreaTap?.call(stopArea),
      )
    );
  }
}