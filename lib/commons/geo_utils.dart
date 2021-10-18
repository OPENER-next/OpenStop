import 'dart:math';
import 'package:latlong2/latlong.dart';

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