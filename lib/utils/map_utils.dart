import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


extension AnimationUtils on MapController {

  /// Animate the map properties location, zoom and rotation.

  animateTo({
    required TickerProvider ticker,
    LatLng? location,
    double? zoom,
    double? rotation,
    Curve curve = Curves.fastOutSlowIn,
    Duration duration = const Duration(milliseconds: 500),
    String? id,
  }) {
    location ??= center;
    zoom ??= this.zoom;
    rotation ??= this.rotation;

    final positionTween = LatLngTween(begin: center, end: location);
    final zoomTween = Tween<double>(begin: this.zoom, end: zoom);
    final rotationTween = RotationTween(begin: this.rotation, end: rotation);

    final controller = AnimationController(
      duration: duration,
      vsync: ticker
    );
    final animation = CurvedAnimation(
        parent: controller,
        curve: curve
    );

    animation.addListener(() {
      moveAndRotate(
        positionTween.evaluate(animation),
        zoomTween.evaluate(animation),
        rotationTween.evaluate(animation),
        id: id
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }


  animateToBounds({
    required TickerProvider ticker,
    required LatLngBounds bounds,
    double maxZoom = 25,
    EdgeInsets padding = EdgeInsets.zero
  }) {
    final centerZoom = centerZoomFitBounds(
      bounds,
      options: FitBoundsOptions(
        maxZoom: maxZoom,
        padding: padding,
        // round zoom level so zoom will always stick to integer levels
        forceIntegerZoomLevel: true,
      )
    );

    animateTo(
      ticker: ticker,
      location: centerZoom.center,
      zoom: centerZoom.zoom,
    );
  }
}


/// Interpolate latitude and longitude values.

class LatLngTween extends Tween<LatLng> {
  static const piDoubled = pi * 2;

  LatLngTween({ LatLng? begin, LatLng? end }) : super(begin: begin, end: end);

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
  RotationTween({ double? begin, double? end }) : super(begin: begin, end: end);

  @override
  double lerp(double t) {
    // thanks to https://stackoverflow.com/questions/2708476/rotation-interpolation
    final rotationDelta = ((end! - begin!) + 180) % 360 - 180;
    return begin! + rotationDelta * t;
  }
}
