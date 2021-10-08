import 'dart:async';
import 'package:flutter/material.dart';
import '/helpers/stop_unifier.dart';
import '/helpers/scaled_marker_plugin.dart';
import '/models/stop.dart';
import '/models/stop_area.dart';
import '/widgets/map_markers/stop_area_indicator.dart';

class StopAreaLayer extends StatefulWidget {
  final Stream<Iterable<Stop>> stopStream;

  final double stopAreaDiameter;

  final double sizeThreshold;

  final void Function(StopArea stopArea)? onStopAreaTap;

  const StopAreaLayer({
    required this.stopStream,
    this.onStopAreaTap,
    this.stopAreaDiameter = 100,
    this.sizeThreshold = 5
  });

  @override
  State<StopAreaLayer> createState() => _StopAreaLayerState();
}


class _StopAreaLayerState extends State<StopAreaLayer> {

  final Map<StopArea, ScaledMarker> _stopAreaMarkers = {};

  StreamSubscription<Iterable<Stop>>? _streamSubscription;

  @override
  void initState() {
    super.initState();
    _subscribeToStream();
  }


  @override
  void didUpdateWidget(StopAreaLayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.stopStream != widget.stopStream) {
      _unsubscribeFromStream();
      _subscribeToStream();
    }
  }


  @override
  Widget build(BuildContext context) {
    return ScaledMarkerLayerWidget(
      options: ScaledMarkerLayerOptions(
        sizeThreshold: widget.sizeThreshold,
        markers: _stopAreaMarkers.values.toList()
      )
    );
  }


  @override
  void dispose() {
    super.dispose();
    _unsubscribeFromStream();
  }


  void _subscribeToStream() {
    _streamSubscription = widget.stopStream.listen(_handleStreamEvent);
  }


  void _unsubscribeFromStream() {
    _streamSubscription?.cancel();
  }


  void _handleStreamEvent(Iterable<Stop> event) {
    setState(() {
      final stopAreas = unifyStops(event, widget.stopAreaDiameter);
      for (final stopArea in stopAreas) {
        _stopAreaMarkers[stopArea] = ScaledMarker(
          size: stopArea.diameter + widget.stopAreaDiameter,
          point: stopArea.center,
          child: StopAreaIndicator(
            onTap: () => _handleStopAreaTap(stopArea)
          )
        );
      }
    });
  }


  void _handleStopAreaTap(StopArea stopArea) {
    setState(() {
      // update related stopArea marker
      _stopAreaMarkers[stopArea] = ScaledMarker(
        // instead of making all markers maintain their state only activate it for markers
        // where their loading animation is active in order to improve performance
        maintainState: true,
        // create unique key based on location
        // this needs to be done so flutter can re-identify the correct element
        key: ValueKey(stopArea.center),
        size: stopArea.diameter + widget.stopAreaDiameter,
        point: stopArea.center,
        child: StopAreaIndicator(
          isLoading: true,
        )
      );
    });
    widget.onStopAreaTap?.call(stopArea);
  }
}