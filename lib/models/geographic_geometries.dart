import 'dart:math';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_math/vector_math_64.dart';


// TODO: Maybe precalculate the center since it might be quite expensive for elements other than point
// maybe also add a "recalculate" method in this case


abstract class GeographicGeometry {
  LatLng get center;

  LatLngBounds get bounds;
}

/// A simple node with latitude and longitude coordinates.
/// This is basically just a class containing a single latLng object.

class GeographicPoint implements GeographicGeometry {
  @override
  final LatLng center;

  const GeographicPoint(this.center);

  @override
  LatLngBounds get bounds => LatLngBounds.fromPoints([center]);
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

    final offset = halfLength - lengths[lowerIndex];
    final bearing = _distance.bearing(lowerPoint, upperPoint);

    return _distance.offset(lowerPoint, offset, bearing);
  }

  @override
  LatLngBounds get bounds => LatLngBounds.fromPoints(path);

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
    assert(
      outerShape.isClosed && this.innerShapes.every((shape) => shape.isClosed),
      'One of the given GeographicPaths is not closed.'
    );
  }

  @override
  LatLngBounds get bounds => outerShape.bounds;

  @override
  LatLng get center => boundingBox.center;

  /// Returns true when this polygon has any holes.

  bool get hasHoles => innerShapes.isNotEmpty;

  /// Returns true when this polygon has no holes.

  bool get hasNoHoles => innerShapes.isEmpty;

  /// Checks whether this polygon contains another polygon.

  bool enclosesPolygon(GeographicPolygon polygon) {
    return enclosesPolyline(polygon.outerShape);
  }

  /// Checks whether this polygon contains the given polyline.

  bool enclosesPolyline(GeographicPolyline polyline) {
    final isInsideOfOuterShape = _pathIsInsidePath(outerShape.path, polyline.path);
    final isOutsideOfInnerShapes = innerShapes.every(
      (innerShape) => _pathIsOutsidePath(innerShape.path, polyline.path)
    );

    return isInsideOfOuterShape && isOutsideOfInnerShapes;
  }


  /// Perform line intersection tests for each pair of lines.
  /// If no intersections occur and one of the line end-points lies inside the polygon,
  /// then the path is entirely inside the polygon.
  /// Note: [closedPath] should resemble a closed shape.

  bool _pathIsInsidePath(List<LatLng> closedPath, List<LatLng> innerPath) {
    assert(closedPath.length > 2 && closedPath.first == closedPath.last, 'Given path is not a closed shape.');
    assert(innerPath.length >= 2, 'Given inner path should at least contain 2 points.');

    // check if arbitrary point is inside the closed path
    // if so and no intersections occurred the path lies within
    return !_pathsIntersect(closedPath, innerPath) && _isPointInsideClosedPath(closedPath, innerPath.first);
  }

  /// Note: [closedPath] should resemble a closed shape.

  bool _pathIsOutsidePath(List<LatLng> closedPath, List<LatLng> outerPath) {
    assert(closedPath.length > 2 && closedPath.first == closedPath.last, 'Given path is not a closed shape.');
    assert(outerPath.length >= 2, 'Given outer path should at least contain 2 points.');

    // check if arbitrary point is not inside the closed path
    // if so and no intersections occurred the path lies within
    return !_pathsIntersect(closedPath, outerPath) && !_isPointInsideClosedPath(closedPath, outerPath.first);
  }


  bool _pathsIntersect(List<LatLng> pathA, List<LatLng> pathB) {
    assert(pathA.length >= 2 && pathB.length >= 2, 'Each given path should at least contain 2 points.');

    for (var i = 1; i < pathA.length; i++) {
      final lineAStart = pathA[i - 1];
      final lineAEnd = pathA[i];

      for (var j = 1; j < pathB.length; j++) {
        final lineBStart = pathB[j - 1];
        final lineBEnd = pathB[j];

        if(_linesIntersect(lineAStart, lineAEnd, lineBStart, lineBEnd)) {
          return true;
        }
      }
    }
    return false;
  }


  bool _linesIntersect(LatLng line1Start, LatLng line1End, LatLng line2Start, LatLng line2End) {
    final line1StartV = _latLngTo3DVector(line1Start);
    final line1EndV = _latLngTo3DVector(line1End);
    final line2StartV = _latLngTo3DVector(line2Start);
    final line2EndV = _latLngTo3DVector(line2End);
    return _intersects(line1StartV, line1EndV, line2StartV, line2EndV);
  }


  _latLngTo3DVector(LatLng coordinate) {
    return Vector3(
      earthRadius * cos(coordinate.latitudeInRad) * cos(coordinate.longitudeInRad),
      earthRadius * cos(coordinate.latitudeInRad) * sin(coordinate.longitudeInRad),
      earthRadius * sin(coordinate.latitudeInRad)
    );
  }

  // derived from: https://stackoverflow.com/a/26669130
  double _det(Vector3 v1, Vector3 v2, Vector3 v3) {
    return v1.dot( v2.cross(v3) );
  }
  bool _straddles(line1StartV, line1EndV, line2StartV, line2EndV) {
    return _det(
      line1StartV, line2StartV, line2EndV) * _det(line1EndV, line2StartV, line2EndV
    ) < 0;
  }
  bool _intersects(line1StartV, line1EndV, line2StartV, line2EndV) {
    return _straddles(line1StartV, line1EndV, line2StartV, line2EndV) &&
           _straddles(line2StartV, line2EndV, line1StartV, line1EndV);
  }


  /// Checks whether this polygon contains the given point.

  bool enclosesPoint(GeographicPoint point) {
    // check if outer contains the given point and all inner do not contain the point
    return _isPointInsideClosedPath(outerShape.path, point.center) &&
      innerShapes.every((shape) => !_isPointInsideClosedPath(shape.path, point.center));
  }


  // derived from: https://stackoverflow.com/a/13951139
  bool _isPointInsideClosedPath(List<LatLng> pathPoints, LatLng point) {
    // pre-check: if the point isn't event located inside the bounding box
    // then it cannot be located inside the polygon
    final bbox = LatLngBounds.fromPoints(pathPoints);
    if (!bbox.contains(point)) {
      return false;
    }

    var lastPoint = pathPoints.last;
    var isInside = false;
    final x = point.longitude;
    for (final pathPoint in pathPoints) {
      var x1 = lastPoint.longitude;
      var x2 = pathPoint.longitude;
      var dx = x2 - x1;

      if (dx.abs() > 180.0) {
        // we have, most likely, just jumped the dateline; normalise the numbers.
        if (x > 0) {
          while (x1 < 0) {
            x1 += 360;
          }
          while (x2 < 0) {
            x2 += 360;
          }
        }
        else {
          while (x1 > 0) {
            x1 -= 360;
          }
          while (x2 > 0) {
            x2 -= 360;
          }
        }
        dx = x2 - x1;
      }

      if ((x1 <= x && x2 > x) || (x1 >= x && x2 < x)) {
        final grad = (pathPoint.latitude - lastPoint.latitude) / dx;
        final intersectAtLat = lastPoint.latitude + ((x - x1) * grad);

        if (intersectAtLat > point.latitude) {
          isInside = !isInside;
        }
      }
      lastPoint = pathPoint;
    }

    return isInside;
  }
}


/// A multi polygon is a list of multiple non-intersecting polygons.

class GeographicMultipolygon implements GeographicGeometry {
  final List<GeographicPolygon> polygons;

  const GeographicMultipolygon(this.polygons);

  @override
  LatLngBounds get bounds {
    return LatLngBounds.fromPoints(
      polygons.expand((polygon) => polygon.outerShape.path).toList()
    );
  }

  @override
  LatLng get center => bounds.center;
}
