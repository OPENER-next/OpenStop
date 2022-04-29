import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '/models/stop.dart';

/// A bundle of multiple nearby [Stop]s.

class StopArea extends Circle {
  static const _distance = Distance();

  final Set<Stop> stops;

  StopArea(
    Iterable<Stop> stops,
    LatLng center,
    double radius,
  ) : stops = Set.unmodifiable(stops), super(center, radius);

  double get diameter => radius + radius;

  /// Returns the bounding box enclosing the stop area circle.

  LatLngBounds get bounds {
    // the offset is the hypotenuse of the triangle where the other sides are equal to the circle radius
    final offset = sqrt(2 * pow(radius, 2));

    final corner1 = _distance.offset(center, offset, 315);
    final corner2 = _distance.offset(center, offset, 135);

    return LatLngBounds(corner1, corner2);
  }

  /// Returns the bounding box enclosing all stops treated as points.

  LatLngBounds get stopBounds {
    return LatLngBounds.fromPoints(
      stops.map<LatLng>((stop) => stop.location).toList(growable: false)
    );
  }

  @override
  String toString() => 'StopArea(stops: $stops, center: $center, radius: $radius)';


  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StopArea &&
      setEquals(other.stops, stops) &&
      other.center == center &&
      other.radius == radius;
  }

  @override
  int get hashCode => Object.hashAll(stops) ^ Object.hash(center, radius);
}
