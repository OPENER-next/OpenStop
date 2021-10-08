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
        rotationTween.evaluate(animation),
        id: id
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
    required LatLngBounds bounds,
    EdgeInsets padding = const EdgeInsets.all(0)
  }) {
    final centerZoom = this.centerZoomFitBounds(
      bounds,
      options: FitBoundsOptions(
        maxZoom: 25,
        padding: padding
      )
    );

    this.animateTo(
      ticker: ticker,
      location: centerZoom.center,
      // round zoom level so zoom will always stick to integer levels
      // floor so the bounds are always visible
      zoom: centerZoom.zoom.floorToDouble()
    );
  }


  animateToCircle({
    required TickerProvider ticker,
    required LatLng center,
    required double radius,
    EdgeInsets padding = const EdgeInsets.all(0)
  }) {
    final distance = Distance();
    final outerBounds = LatLngBounds(
      distance.offset(
        distance.offset(center, radius, 0),
        radius,
        90
      ),
      distance.offset(
        distance.offset(center, radius, 180),
        radius,
        270
      ),
    );

    this.animateToBounds(
      ticker: ticker,
      bounds: outerBounds,
      padding: padding
    );
  }
}
