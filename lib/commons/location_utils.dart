import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';


Future<LatLng?> acquireCurrentLocation() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // permissions are denied don't continue
      return null;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // permissions are denied forever don't continue
    return null;
  }

  // if permissions are granted try to access the position of the device
  // on android the user will be automatically asked if he wants to enable the location service if it is disabled
  try {
    final location = await Geolocator.getCurrentPosition();
    return LatLng(location.latitude, location.longitude);
  }
  on LocationServiceDisabledException {
    return null;
  }
}