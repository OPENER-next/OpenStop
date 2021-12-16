import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


// TODO: Maybe precalculate the center since it might be quite expensive for elements other than point
// maybe also add a "recalculate" method in this case


abstract class GeographicGeometry {
  LatLng get center;
}

/// A simple node with latitude and longitude coordinates.
/// This is basically just a class containing a single latLng object.

class GeographicPoint implements GeographicGeometry {
  @override
  final LatLng center;

  const GeographicPoint(this.center);
}

/// A list of coordinates that build a connection of multiple lines.
/// The last and the first point might be identical and therefore form a closed shape.
/// However this element should still be treated and drawn as a set of lines with no fill.

class GeographicPolyline implements GeographicGeometry {
  static const Distance _distance = Distance();

  final List<LatLng> path;

  const GeographicPolyline(this.path);

  /// The center of a polyline is always positioned on the path at the half of the total path length.

  @override
  LatLng get center {
    // all accumulated lengths, where the last element is equal to the total length
    final lengths = <double>[0];
    for (var i = 0; i < path.length - 1; i++) {
      lengths.add(
        lengths.last + _distance.distance(path[i], path[i + 1])
      );
    }
    final halfLength = lengths.last/2;

    // search for the last length that is still shorter than half of the total length
    final lowerIndex = lengths.lastIndexWhere((length) => length < halfLength);
    final upperIndex = lowerIndex + 1;

    final lowerPoint = path[lowerIndex];
    final upperPoint = path[upperIndex];

    return _distance.offset(
      lowerPoint,
      lengths[upperIndex] - lengths[lowerIndex],
      _distance.bearing(lowerPoint, upperPoint)
    );
  }

  bool get isClosed => path.length > 2 && path.first == path.last;
}

/// A simple polygon is based of one outer shape which is represented by a closed polyline.
/// Optionally a complex polygon might contain multiple holes which are likewise defined as closed polylines.

class GeographicPolygon implements GeographicGeometry {
  final GeographicPolyline outerShape;
  final List<GeographicPolyline> innerShapes;

  GeographicPolygon({
    required this.outerShape,
    List<GeographicPolyline>? innerShapes
  }) : innerShapes = innerShapes ?? [] {
    if (!outerShape.isClosed || this.innerShapes.any((shape) => !shape.isClosed)) {
      throw AssertionError('One of the given GeographicPaths is not closed.');
    }
  }

  LatLngBounds get boundingBox => LatLngBounds.fromPoints(outerShape.path);

  @override
  LatLng get center => boundingBox.center;

  /// Returns true when this polygon has no holes.

  bool get isSimple => innerShapes.isEmpty;
}


/// A multi polygon is a list of multiple non-intersecting polygons.

class GeographicMultipolygon implements GeographicGeometry {
  final List<GeographicPolygon> polygons;

  const GeographicMultipolygon(this.polygons);

  LatLngBounds get boundingBox {
    return LatLngBounds.fromPoints(
      polygons.expand((polygon) => polygon.outerShape.path).toList()
    );
  }

  @override
  LatLng get center => boundingBox.center;
}
