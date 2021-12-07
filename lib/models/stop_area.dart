import 'package:collection/collection.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '/models/stop.dart';

/// A bundle of multiple nearby [Stop]s.

class StopArea {
  static const _distance = Distance();

  final Set<Stop> stops;

  late final LatLngBounds bounds;

  late final double diameter;

  StopArea(
    Iterable<Stop> stops
  ) : stops = Set.unmodifiable(stops) {
    bounds = _calculateBounds();
    diameter = _calculateDiameter();
  }

  LatLng get center => bounds.center;

  LatLngBounds _calculateBounds() {
    return LatLngBounds.fromPoints(
      stops.map<LatLng>((stop) => stop.location).toList(growable: false)
    );
  }

  double _calculateDiameter() {
    return _distance(bounds.northWest, bounds.southEast);
  }

  @override
  String toString() => 'StopArea(stops: $stops, bounds: $bounds, diameter: $diameter)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final setEquals = const DeepCollectionEquality().equals;

    return other is StopArea &&
      setEquals(other.stops, stops) &&
      other.bounds == bounds &&
      other.diameter == diameter;
  }

  @override
  int get hashCode => stops.hashCode ^ bounds.hashCode ^ diameter.hashCode;
}
