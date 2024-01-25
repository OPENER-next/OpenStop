// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';
import 'package:flutter_map/flutter_map.dart';

/// Earth circumference in meters
const earthCircumference = 2 * pi * earthRadius;

/// Length in meters of 1° of latitude
const metersPerLatitude = earthCircumference / 360;


double metersPerPixel(double latitude, double zoomLevel) {
  final latitudeRadians = latitude * (pi/180);
  return earthCircumference * cos(latitudeRadians) / pow(2, zoomLevel + 8);
}


double pixelValue(double latitude, double meters, double zoomLevel) {
  return meters / metersPerPixel(latitude, zoomLevel);
}

extension LatLngBoundsExtensions on LatLngBounds {

  /// Mirrors the underlying bbox at a given point in latitude and longitude.
  ///
  /// Creates and returns a new [LatLngBounds].

  LatLngBounds mirror(LatLng point) {
    final newNorthWest = LatLng(
      point.latitude + point.latitude - northWest.latitude,
      point.longitude + point.longitude - northWest.longitude,
    );
    final newSouthEast = LatLng(
      point.latitude + point.latitude - southEast.latitude,
      point.longitude + point.longitude - southEast.longitude,
    );

    return LatLngBounds(newNorthWest, newSouthEast);
  }
}
