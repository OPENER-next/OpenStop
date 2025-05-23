import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '/models/geographic_geometries.dart';

/// Displays a given geographic geometry on the map.

class GeometryLayer extends StatelessWidget {
  final GeographicGeometry geometry;

  const GeometryLayer({
    required this.geometry,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary.withValues(alpha: 0.75);
    final Widget layer;

    if (geometry is GeographicPolyline) {
      final polyline = geometry as GeographicPolyline;
      layer = PolylineLayer(
        polylines: [
          Polyline(
            points: polyline.path,
            color: color,
            strokeWidth: 8,
          ),
        ],
      );
    } else if (geometry is GeographicPolygon || geometry is GeographicMultipolygon) {
      final polygons = geometry is GeographicPolygon
          ? [(geometry as GeographicPolygon)]
          : (geometry as GeographicMultipolygon).polygons;

      layer = PolygonLayer(
        polygons: polygons
            .map(
              (polygon) => Polygon(
                points: polygon.outerShape.path,
                holePointsList: polygon.innerShapes.map((item) => item.path).toList(),
                color: color,
                borderStrokeWidth: 8,
                borderColor: color,
              ),
            )
            .toList(),
      );
    }
    // TODO: Render individual elements of GeographicCollections instead of only center point.
    else {
      layer = CircleLayer(
        circles: [
          CircleMarker(
            point: geometry.center,
            radius: 8,
            color: color,
          ),
        ],
      );
    }

    return IgnorePointer(
      child: layer,
    );
  }
}
