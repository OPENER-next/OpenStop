
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '/utils/map_utils.dart';

class CameraTracker extends ChangeNotifier implements TickerProvider {
  final MapController mapController;

  final Duration updateInterval;

  final Duration timeout;

  StreamSubscription<MapEvent>? _mapEventStreamSub;

  StreamSubscription<Position>? _positionStreamSub;

  StreamSubscription<ServiceStatus>? _serviceStatusStreamSub;

  Ticker? _ticker;

  CameraTrackerState _state = CameraTrackerState.inactive;

  /// Whether the location permission has been granted and the location service has been enabled or not.
  /// This only changes after calls to [startTacking] since there is no permission notification API.

  bool hasLocationAccess = false;

  CameraTracker({
    required this.mapController,
    this.updateInterval = const Duration(milliseconds: 300),
    this.timeout = const Duration(seconds: 4)
  }) : super();


  CameraTrackerState get state => _state;

  /// This function will automatically request permissions and the activation of the location service.
  /// Only call this function if the [MapController] is ready ([onReady]). Otherwise an error might occur.

  void startTacking({double? initialZoom}) async {
    if (_state != CameraTrackerState.inactive) return;

    _updateState(CameraTrackerState.pending);

    // request permissions and get last known position
    final lastPosition = await _acquireUserLocation(false);

    hasLocationAccess = lastPosition != null;

    // if location was successfully granted and retrieved
    // and if state is still pending which means it wasn't canceled during the process
    if (hasLocationAccess && _state == CameraTrackerState.pending) {
      // move to last known location if available
      _handlePositionUpdate(lastPosition!, initialZoom);

      _positionStreamSub = Geolocator.getPositionStream(
        locationSettings: AndroidSettings(
          intervalDuration: updateInterval,
          timeLimit: timeout
        )
      ).listen(_handlePositionUpdate, onError: (e) => stopTracking);

      _serviceStatusStreamSub = Geolocator.getServiceStatusStream().listen(_handleServiceStatus);

      _mapEventStreamSub = mapController.mapEventStream.listen(_handleMapEvent, onError: (e) => stopTracking);

      if (_ticker?.isActive == false) _ticker?.start();

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
    _ticker?.stop();

    _updateState(CameraTrackerState.inactive);
  }


  /// This function will automatically request permissions if not already granted
  /// as well as the activation of the device's location service if not already activated.
  /// If [forceCurrent] is set to [true] this function will directly try to gather the most up-to-date position.
  /// Else the last known position will preferably be returned if available.

  Future<Position?> _acquireUserLocation([forceCurrent = true]) async {
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
      return lastPosition ?? await Geolocator.getCurrentPosition();
    }
    on LocationServiceDisabledException {
      return null;
    }
  }


  _updateState(CameraTrackerState newState) {
    if (newState != _state) {
      _state = newState;
      notifyListeners();
    }
  }


  void _handlePositionUpdate(Position position, [double? zoom]) {
    mapController.animateTo(
      ticker: this,
      location: LatLng(position.latitude, position.longitude),
      zoom: zoom,
      duration: updateInterval,
      id: 'CameraTracker'
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
      (mapEvent is MapEventMove && mapEvent.id != 'CameraTracker' && mapEvent.targetCenter != mapEvent.center)
    ) {
      stopTracking();
    }
  }


  @override
  Ticker createTicker(TickerCallback onTick) {
    _ticker = Ticker(onTick, debugLabel: kDebugMode ? 'created by ${describeIdentity(this)}' : null);
    return _ticker!;
  }


  @override
  void dispose() {
    _positionStreamSub?.cancel();
    _serviceStatusStreamSub?.cancel();
    _mapEventStreamSub?.cancel();
    _ticker?.stop();

    super.dispose();
  }
}

/// Pending means that the tracking has been requested, but at this point
/// it's unclear if the user grants the permissions or enables the location service.

enum CameraTrackerState {
  pending,
  active,
  inactive
}
