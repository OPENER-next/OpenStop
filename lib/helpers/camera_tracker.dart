
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '/commons/map_utils.dart';
import '/commons/location_utils.dart';

class CameraTracker extends ChangeNotifier {
  final TickerProvider ticker;

  final MapController mapController;

  final Duration updateInterval;

  final Duration timeout;

  StreamSubscription<MapEvent>? _mapEventStreamSub;

  StreamSubscription<Position>? _positionStreamSub;

  StreamSubscription<ServiceStatus>? _serviceStatusStreamSub;

  bool _isActive = false;

  CameraTracker({
    required this.ticker,
    required this.mapController,
    this.updateInterval = const Duration(milliseconds: 300),
    this.timeout = const Duration(seconds: 4)
  }) : super();


  get isActive => _isActive;


  /// This function will automatically request permissions and the activation of the location service.
  /// Only call this function if the [MapController] is ready ([onReady]). Otherwise an error might occur.

  void startTacking() async {
    if (isActive) return;

    final location = await acquireCurrentLocation(false);
    if (location != null) {
      // move to last known location
      _updateCamera(location);

      _positionStreamSub = Geolocator.getPositionStream(
        intervalDuration: this.updateInterval,
        timeLimit: timeout
      ).listen(_updateCamera, onError: (e) => stopTracking);

      _serviceStatusStreamSub = Geolocator.getServiceStatusStream().listen(_handleServiceStatus);
      _mapEventStreamSub = mapController.mapEventStream.listen(_handleMapEvent, onError: (e) => stopTracking);

      _isActive = true;
      notifyListeners();
    }
  }


  void stopTracking() {
    if (!isActive) return;

    _positionStreamSub?.cancel();
    _serviceStatusStreamSub?.cancel();
    _mapEventStreamSub?.cancel();

    _isActive = false;
    notifyListeners();
  }


  void _updateCamera(Position position) {
    mapController.animateTo(
      ticker: ticker,
      location: LatLng(position.latitude, position.longitude),
      duration: updateInterval,
      id: "CameraTracker"
    );
  }

  void _handleServiceStatus(ServiceStatus status) {
    // cancel tracking when location service gets disabled
    if (status == ServiceStatus.disabled) {
      stopTracking();
    }
  }

  void _handleMapEvent(MapEvent mapEvent) {
    // cancel tracking on user interaction or any map move not caused by the camera tracker
    if (
      (mapEvent.source == MapEventSource.onDrag) ||
      (mapEvent is MapEventMove && mapEvent.id != "CameraTracker")
    ) {
      stopTracking();
    }
  }
}