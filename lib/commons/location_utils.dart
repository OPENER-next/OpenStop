import 'package:geolocator/geolocator.dart';

/// This function will automatically request permissions if not already granted
/// as well as the activation of the device's location service if not already activated.
/// If [forceCurrent] is set to [true] this function will directly try to gather the most up-to-date position.
/// Else the last known position will preferably be returned if available.

Future<Position?> acquireUserLocation([forceCurrent = true]) async {
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
    Position? lastPosition;
    if (!forceCurrent) {
      lastPosition = await Geolocator.getLastKnownPosition();
    }
    // if no previous position is known automatically try to get the current one
    return lastPosition == null ? await Geolocator.getCurrentPosition() : lastPosition;
  }
  on LocationServiceDisabledException {
    return null;
  }
}