import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'points_layer.dart';


class StopsLayer extends StatelessWidget {

  final Iterable<LatLng> unloadedStops;

  final Iterable<LatLng> completedStops;

  final Iterable<LatLng> incompleteStops;

  /// The current zoom level.

  final num currentZoom;

  /// The lowest zoom level on which the layer is still visible.

  final num lowerZoomLimit;

  /// The biggest zoom level on which the layer is still visible.

  final num upperZoomLimit;

  const StopsLayer({
    required this.unloadedStops,
    required this.completedStops,
    required this.incompleteStops,
    required this.currentZoom,
    this.lowerZoomLimit = 9,
    this.upperZoomLimit = 16,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child:
        currentZoom >= upperZoomLimit || currentZoom <= lowerZoomLimit
        ? null
        : Stack(
          children: [
            PointsLayer(
              points: unloadedStops,
              color: Colors.grey.shade400,
              radius: 5,
            ),
            PointsLayer(
              points: incompleteStops,
              color: theme.colorScheme.primary,
              radius: 5,
            ),
            PointsLayer(
              points: completedStops,
              color: const Color(0xFF8ccf73),
              radius: 5,
            ),
          ],
        ),
    );
  }
}
