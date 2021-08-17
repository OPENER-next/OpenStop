import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl/mapbox_gl.dart';


Future<LatLng?> acquireCurrentLocation() async {
  // Test if location services are enabled.
  final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    return null;
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied don't continue
      return null;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever don't continue
    return null;
  }

  // permissions are granted
  // continue accessing the position of the device.
  final location = await Geolocator.getCurrentPosition();
  return LatLng(location.latitude, location.longitude);
}