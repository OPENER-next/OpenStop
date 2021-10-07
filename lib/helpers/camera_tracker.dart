
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

  CameraTrackerState _state = CameraTrackerState.inactive;

  CameraTracker({
    required this.ticker,
    required this.mapController,
    this.updateInterval = const Duration(milliseconds: 300),
    this.timeout = const Duration(seconds: 4)
  }) : super();


  get state => _state;

  /// This function will automatically request permissions and the activation of the location service.
  /// Only call this function if the [MapController] is ready ([onReady]). Otherwise an error might occur.

  void startTacking({double? defaultZoom}) async {
    if (_state != CameraTrackerState.inactive) return;

    _updateState(CameraTrackerState.pending);

    // request permissions and get last known position
    final lastPosition = await acquireUserLocation(false);
    // if location was successfully granted and retrieved
    // and if state is still pending which means it wasn't canceled during the process
    if (lastPosition != null && _state == CameraTrackerState.pending) {
      // move to last known location if available
      _handlePositionUpdate(lastPosition, defaultZoom);

      _positionStreamSub = Geolocator.getPositionStream(
        intervalDuration: this.updateInterval,
        timeLimit: timeout
      ).listen(_handlePositionUpdate, onError: (e) => stopTracking);

      _serviceStatusStreamSub = Geolocator.getServiceStatusStream().listen(_handleServiceStatus);

      _mapEventStreamSub = mapController.mapEventStream.listen(_handleMapEvent, onError: (e) => stopTracking);

      _updateState(CameraTrackerState.active);
    }
    else {
      _updateState(CameraTrackerState.inactive);
    }
  }


  void stopTracking() {
    if (_state == CameraTrackerState.inactive) return;

    _positionStreamSub?.cancel();
    _serviceStatusStreamSub?.cancel();
    _mapEventStreamSub?.cancel();

    _updateState(CameraTrackerState.inactive);
  }


  _updateState(CameraTrackerState newState) {
    if (newState != _state) {
      _state = newState;
      notifyListeners();
    }
  }


  void _handlePositionUpdate(Position position, [double? zoom]) {
    mapController.animateTo(
      ticker: ticker,
      location: LatLng(position.latitude, position.longitude),
      zoom: zoom,
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
      (mapEvent is MapEventDoubleTapZoomStart) ||
      (mapEvent is MapEventMove && mapEvent.id != "CameraTracker" && mapEvent.targetCenter != mapEvent.center)
    ) {
      stopTracking();
    }
  }
}

/// Pending means that the tracking has been requested, but at this point
/// it's unclear if the user grants the permissions or enables the location service.

enum CameraTrackerState {
  pending,
  active,
  inactive
}