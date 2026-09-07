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

  StopArea(
    LatLng corner1,
    LatLng corner2, {
    this.name,
  }) : super.unsafe(
         north: corner2.latitude,
         east: corner2.longitude,
         south: corner1.latitude,
         west: corner1.longitude,
       );

  factory StopArea.fromCSV(List<String> row) {
    try {
      return StopArea(
        LatLng(double.parse(row[0]), double.parse(row[1])),
        LatLng(double.parse(row[2]), double.parse(row[3])),
        name: row[4].isEmpty ? null : row[4],
      );
    } catch (e) {
      throw Exception('Invalid CSV data: $e');
    }
  }

  @override
  String toString() => 'StopArea($southWest; $northEast; name: $name)';
}
