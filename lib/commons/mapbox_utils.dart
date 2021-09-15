import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import '/commons/location_utils.dart';

/// Update the current map view position to a given location

Future<void> moveToLocation({required MapboxMapController mapController, required LatLng location, double paddingLeft = 0, double paddingTop = 0, double paddingRight = 0, double paddingBottom = 0, LatLng extend = const LatLng(0.001, 0.001)}) async {
  await mapController.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(southwest: location - extend, northeast: location + extend),
      left: paddingLeft,
      top: paddingTop,
      right: paddingRight,
      bottom: paddingBottom
      )
  );
}


/// Acquire current location and update map view position
/// Moves the camera to the current user location

Future<bool> moveToUserLocation({required MapboxMapController mapController, double paddingLeft = 0, double paddingTop = 0, double paddingRight = 0, double paddingBottom = 0, LatLng extend = const LatLng(0.001, 0.001)}) async {
  final location = await acquireCurrentLocation();
  if (location != null) {
     await moveToLocation(
          mapController: mapController,
          location: location,
          paddingLeft: paddingLeft,
          paddingTop: paddingTop,
          paddingRight: paddingRight,
          paddingBottom: paddingBottom,
          extend: extend
     );
     return true;
  }
  return false;
}


/// This enables mapbox user location tracking which will move the camera to the user's position.
/// If either the location permission is not granted or the location service is disabled the user will be prompted to grant/enable it.

Future<void> trackUserLocation(MapboxMapController mapController) async {
  final permissions = await Geolocator.checkPermission();
  if (permissions == LocationPermission.always || permissions == LocationPermission.whileInUse) {
    if (await Geolocator.isLocationServiceEnabled()) {
      return mapController.updateMyLocationTrackingMode(MyLocationTrackingMode.Tracking);
    }
  }
  // this method will automatically request permissions and the location service
  // on success it will return the current position else null
  final location = await acquireCurrentLocation();
  if (location != null) {
    return mapController.updateMyLocationTrackingMode(MyLocationTrackingMode.Tracking);
  }
}