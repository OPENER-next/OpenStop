import 'package:geolocator/geolocator.dart';

/// This function will automatically request permissions if not already granted
/// as well as the activation of the device's location service if not already activated.
/// If [waitForCurrent] is set to true this function will try to gather the up-to-date position.
/// Else the last known position will be returned.

Future<Position?> acquireCurrentLocation([waitForCurrent = true]) async {
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
    return waitForCurrent
    ? await Geolocator.getCurrentPosition()
    : await Geolocator.getLastKnownPosition();
  }
  on LocationServiceDisabledException {
    return null;
  }
}