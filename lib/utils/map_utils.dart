import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


extension AnimationUtils on MapController {

  /// Animate the map properties location, zoom and rotation.

  TickerFuture animateTo({
    required TickerProvider ticker,
    LatLng? location,
    double? zoom,
    double? rotation,
    Curve curve = Curves.fastOutSlowIn,
    Duration duration = const Duration(milliseconds: 500),
    String? id,
  }) {
    final positionTween = location != null
      ? LatLngTween(begin: camera.center, end: location)
      : null;
    final zoomTween = zoom != null
      ? Tween<double>(begin: camera.zoom, end: zoom)
      : null;
    final rotationTween = rotation != null
      ? RotationTween(begin: camera.rotation, end: rotation)
      : null;

    final controller = AnimationController(
      duration: duration,
      vsync: ticker,
    );
    final animation = CurvedAnimation(
      parent: controller,
      curve: curve,
    );

    animation.addListener(() {
      moveAndRotate(
        // use most up to date camera value if no tween/animation was specified
        positionTween?.evaluate(animation) ?? camera.center,
        zoomTween?.evaluate(animation) ?? camera.zoom,
        rotationTween?.evaluate(animation) ?? camera.rotation,
        id: id,
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    return controller.forward();
  }


  TickerFuture animateToBounds({
    required TickerProvider ticker,
    required LatLngBounds bounds,
    double maxZoom = 25,
    double minZoom = 0,
    EdgeInsets padding = EdgeInsets.zero
  }) {
    final newCamera = CameraFit.bounds(
      bounds: bounds,
      maxZoom: maxZoom,
      minZoom: minZoom,
      padding: padding,
      // round zoom level so zoom will always stick to integer levels
      forceIntegerZoomLevel: true,
    ).fit(camera);

    return animateTo(
      ticker: ticker,
      location: newCamera.center,
      zoom: newCamera.zoom,
    );
  }
}


/// Interpolate latitude and longitude values.

class LatLngTween extends Tween<LatLng> {
  static const piDoubled = pi * 2;

  LatLngTween({ super.begin, super.end });

  @override
  LatLng lerp(double t) {
    // latitude varies from [90, -90]
    // longitude varies from [180, -180]

    final latitudeDelta = end!.latitude - begin!.latitude;
    final latitude = begin!.latitude + latitudeDelta * t;

    // calculate longitude in range of [0 - 360]
    final longitudeDelta = _wrapDegrees(end!.longitude - begin!.longitude);
    var longitude = begin!.longitude + longitudeDelta * t;
    // wrap back to [180, -180]
    longitude = _wrapDegrees(longitude);

    return LatLng(latitude, longitude);
  }

  double _wrapDegrees(v) => (v + 180) % 360 - 180;
}


/// Interpolate radians values in the direction of the shortest rotation delta / rotation angle.

class RotationTween extends Tween<double> {
  RotationTween({ super.begin, super.end });

  @override
  double lerp(double t) {
    // thanks to https://stackoverflow.com/questions/2708476/rotation-interpolation
    final rotationDelta = ((end! - begin!) + 180) % 360 - 180;
    return begin! + rotationDelta * t;
  }
}
