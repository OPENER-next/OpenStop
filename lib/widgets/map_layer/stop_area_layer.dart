import 'package:flutter/material.dart';
import '/helpers/scaled_marker_plugin.dart';
import '/models/stop_area.dart';
import '/widgets/map_markers/stop_area_indicator.dart';

class StopAreaLayer extends StatelessWidget {
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
    this.sizeThreshold = 5
  });


  @override
  Widget build(BuildContext context) {
    return ScaledMarkerLayerWidget(
      options: ScaledMarkerLayerOptions(
        sizeThreshold: sizeThreshold,
        markers: _createMarkers()
      )
    );
  }


  List<ScaledMarker> _createMarkers() {
    return stopAreas.map((stopArea) {
      return _createMarker(
        stopArea,
        loadingStopAreas.contains(stopArea)
      );
    }).toList();
  }


  ScaledMarker _createMarker(StopArea stopArea, bool isLoading) {
    // update related stopArea marker
    return ScaledMarker(
      // instead of making all markers maintain their state only activate it for markers
      // where their loading animation is active in order to improve performance
      maintainState: isLoading,
      // create unique key based on location
      // this needs to be done so flutter can re-identify the correct element
      key: isLoading ? ValueKey(stopArea.center) : null,
      size: stopArea.diameter + stopAreaDiameter,
      point: stopArea.center,
      child: StopAreaIndicator(
        isLoading: isLoading,
        onTap: () => onStopAreaTap?.call(stopArea),
      )
    );
  }
}