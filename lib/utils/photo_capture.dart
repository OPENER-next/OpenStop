import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

/// iOS's in-app camera supplies a capture time but does not geotag its images.
/// Track actual device locations while the camera is open, then retain the fix
/// nearest the original capture time for upload without changing the file.
/// Never use this for library imports.
Future<({XFile image, ({double latitude, double longitude}) Function(DateTime) locationAt})?>
capturePhotoWithLocation(
  Future<XFile?> Function() capture,
) async {
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
    throw const PermissionDeniedException('Camera capture requires location permission');
  }

  const settings = LocationSettings(accuracy: LocationAccuracy.best);
  final positions = [
    await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        // Do not leave the camera action waiting indefinitely for a GPS fix.
        timeLimit: Duration(seconds: 20),
      ),
    ),
  ];
  final subscription = Geolocator.getPositionStream(locationSettings: settings).listen(
    positions.add,
    // A stream failure must not supply a fabricated or stale capture location.
    onError: (Object _) {},
  );
  XFile? image;
  try {
    image = await capture();
  } finally {
    await subscription.cancel();
  }
  if (image == null) return null;

  ({double latitude, double longitude}) locationAt(DateTime capturedAt) {
    final position = positions.reduce(
      (a, b) => a.timestamp.difference(capturedAt).abs() <= b.timestamp.difference(capturedAt).abs()
          ? a
          : b,
    );
    // Allow GPS update delays, but reject old fixes after a long camera session.
    if (position.timestamp.difference(capturedAt).abs() > const Duration(seconds: 30)) {
      throw TimeoutException('No location near the capture time');
    }
    return (latitude: position.latitude, longitude: position.longitude);
  }

  return (image: image, locationAt: locationAt);
}
