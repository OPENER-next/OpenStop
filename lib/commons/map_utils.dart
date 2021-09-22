import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/*


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


*/


extension AnimationUtils on MapController {

  /// Animate the map properties location, zoom and rotation.

  animateTo({
    required TickerProvider ticker,
    LatLng? location,
    double? zoom,
    double? rotation,
    Curve curve = Curves.fastOutSlowIn,
    Duration duration = const Duration(milliseconds: 500)
  }) {
    location ??= this.center;
    zoom ??= this.zoom;
    rotation ??= this.rotation;

    final latTween = Tween<double>(begin: this.center.latitude, end: location.latitude);
    final lngTween = Tween<double>(begin: this.center.longitude, end: location.longitude);
    final zoomTween = Tween<double>(begin: this.zoom, end: zoom);
    final rotationTween = Tween<double>(begin: this.rotation, end: rotation);

    final controller = AnimationController(
      duration: duration,
      vsync: ticker
    );
    Animation<double> animation = CurvedAnimation(parent: controller, curve: curve);

    animation.addListener(() {
      this.moveAndRotate(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
        rotationTween.evaluate(animation)
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }


  animateToBounds({
    required TickerProvider ticker,
    required LatLng location,
    LatLng? extend,
    EdgeInsets padding = const EdgeInsets.all(0)
  }) {
    extend ??= LatLng(0.001, 0.001);

    var centerZoom = this.centerZoomFitBounds(
      LatLngBounds(
        LatLng(
          location.latitude - extend.latitude,
          location.longitude - extend.longitude
        ),
        LatLng(
          location.latitude + extend.latitude,
          location.longitude + extend.longitude
        ),
      ),
      options: FitBoundsOptions(
        maxZoom: 25,
        padding: padding
      )
    );

    this.animateTo(
      ticker: ticker,
      location: centerZoom.center,
      zoom: centerZoom.zoom
    );
  }
}
