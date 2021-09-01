import '/commons/location_utils.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

const extend =  LatLng(0.001, 0.001);

/// Update the current map view position to a given location

Future<void> moveTo(MapboxMapController mapController, LatLng location, double paddingBottom) async {
  await mapController.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(southwest: location - extend, northeast: location + extend),
      bottom: paddingBottom
      )
  );
}


/// Acquire current location and update map view position
/// Moves the camera to the current user location

Future<bool> moveToUserLocation(MapboxMapController mapController, double paddingBottom) async {
  final location = await acquireCurrentLocation();
  if (location != null) {
      moveTo(mapController, location, paddingBottom);
  }
  return location != null;
}


