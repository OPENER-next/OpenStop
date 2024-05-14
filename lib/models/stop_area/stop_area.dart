import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


/// An area covering one or multiple stops, ways and other POIs.

class StopArea extends LatLngBounds {
  final String? name;

  /// The circumcircle around the bounding box.
  // lazily calculate the value and store it for future use
  late final Circle circumcircle = Circle(
    center,
    const Distance().distance(southWest, northEast) / 2,
  );

  StopArea(super.corner1, super.corner2, {
    this.name,
  });

  @override
  String toString() => 'StopArea($southWest; $northEast; name: $name)';
}
