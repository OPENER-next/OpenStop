import 'package:collection/collection.dart';
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
    final corner1 = _distance.offset(
      _distance.offset(center, radius, 0),
      radius,
      270
    );
    final corner2 = _distance.offset(
      _distance.offset(center, radius, 180),
      radius,
      90
    );

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
    final setEquals = const DeepCollectionEquality().equals;

    return other is StopArea &&
      setEquals(other.stops, stops) &&
      other.center == center &&
      other.radius == radius;
  }

  @override
  int get hashCode => stops.hashCode ^ center.hashCode ^ radius.hashCode;
}
