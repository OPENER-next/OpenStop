import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '/utils/stream_utils.dart';
import 'points_layer.dart';


class StopsLayer extends StatelessWidget {

  final Iterable<LatLng> unloadedStops;

  final Iterable<LatLng> completedStops;

  final Iterable<LatLng> incompleteStops;

  /// The lowest zoom level on which the layer is still visible.

  final int lowerZoomLimit;

  /// The biggest zoom level on which the layer is still visible.

  final int upperZoomLimit;

  const StopsLayer({
    required this.unloadedStops,
    required this.completedStops,
    required this.incompleteStops,
    this.lowerZoomLimit = 9,
    this.upperZoomLimit = 16,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mapController = context.read<MapController>();

    return StreamBuilder(
      stream: mapController.mapEventStream
        .whereType<MapEventWithMove>()
        .map((event) => event.targetZoom.round())
        .transform(ComparePreviousTransformer(
          (previous, current) => previous != current
        )),
      builder: (context, AsyncSnapshot<int> snapshot) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: !snapshot.hasData
          || snapshot.requireData >= upperZoomLimit
          || snapshot.requireData <= lowerZoomLimit
            ? null
            : Stack(
              children: [
                PointsLayer(
                  points: unloadedStops,
                  color: Colors.grey.shade400,
                  radius: 3,
                ),
                PointsLayer(
                  points: incompleteStops,
                  color: theme.colorScheme.primary,
                  radius: 3,
                ),
                PointsLayer(
                  points: completedStops,
                  color: const Color(0xFF8ccf73),
                  radius: 3,
                ),
              ],
            ),
        );
      }
    );
  }
}
