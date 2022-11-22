import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class UserLocationProvider extends ChangeNotifier {

  LocationTrackingState _state = LocationTrackingState.disabled;

  /// Whether the location permission has been granted and the location service has been enabled or not.
  /// This only changes after calls to [startTracking] since there is no permission notification API.
  /// Pending means that the tracking has been requested, but at this point
  /// it's unclear if the user grants the permissions or enables the location service.

  LocationTrackingState get state => _state;

  Position? _position;

  /// The last known position if any.

  Position? get position => _position;

  bool _shouldFollowLocation = false;

  /// Whether the camera should follow the user's position or not.

  bool get shouldFollowLocation => _shouldFollowLocation;

  set shouldFollowLocation(bool value) {
    if (value != _shouldFollowLocation) {
      _shouldFollowLocation = value;
      notifyListeners();
    }
  }

  /// Whether the location service is enabled and the location should be followed.

  get isFollowingLocation {
    return _shouldFollowLocation && _state == LocationTrackingState.enabled;
  }

  final LocationSettings _locationSettings;

  StreamSubscription<Position>? _positionNotifierStreamSub;

  StreamSubscription<ServiceStatus>? _serviceStatusStreamSub;

  UserLocationProvider({
    Duration updateInterval = const Duration(milliseconds: 300),
    int distanceThreshold = 1,
  }) : _locationSettings = AndroidSettings(
    intervalDuration: updateInterval,
    distanceFilter: distanceThreshold
  ), super();



  /// This function will automatically request permissions and the activation of the location service.

  void startLocationTracking() async {
    if (_state != LocationTrackingState.disabled) return;

    _updateState(LocationTrackingState.pending);

    // request permissions and get last known position
    final lastPosition = await _acquireUserLocation(false);

    // if location was successfully granted and retrieved
    // and if state is still pending which means it wasn't canceled during the process
    if (lastPosition != null && _state == LocationTrackingState.pending) {
      // move to last known location if available
      _updatePosition(lastPosition);

      _positionNotifierStreamSub = Geolocator.getPositionStream(
        locationSettings: _locationSettings
      ).listen(_updatePosition, onError: (e) => stopLocationTracking());

      try {
        _serviceStatusStreamSub = Geolocator.getServiceStatusStream().listen(_handleServiceStatus);
      }
      on UnimplementedError {
        // getServiceStatusStream is not supported on web
      }

      _updateState(LocationTrackingState.enabled);
    }
    else {
      _updateState(LocationTrackingState.disabled);
    }
  }


  void stopLocationTracking() {
    if (_state == LocationTrackingState.disabled) return;

    _positionNotifierStreamSub?.cancel();
    _serviceStatusStreamSub?.cancel();

    _updateState(LocationTrackingState.disabled);
  }


  void _updateState(LocationTrackingState newState) {
    if (newState != _state) {
      _state = newState;
      notifyListeners();
    }
  }


  void _updatePosition(Position newPosition) {
    if (newPosition != _position) {
      _position = newPosition;
      notifyListeners();
    }
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
        try {
          lastPosition = await Geolocator.getLastKnownPosition();
        }
        on PlatformException {
          // getLastKnownPosition is not supported on web
        }
      }
      // if no previous position is known automatically try to get the current one
      return lastPosition ?? await Geolocator.getCurrentPosition();
    }
    on LocationServiceDisabledException {
      return null;
    }
  }


  void _handleServiceStatus(ServiceStatus status) {
    // cancel tracking when location service gets disabled
    if (status == ServiceStatus.disabled) {
      stopLocationTracking();
    }
  }


  @override
  void dispose() {
    _positionNotifierStreamSub?.cancel();
    _serviceStatusStreamSub?.cancel();
    super.dispose();
  }
}

/// Pending means that the tracking has been requested, but at this point
/// it's unclear if the user grants the permissions or enables the location service.

enum LocationTrackingState {
  pending,
  enabled,
  disabled
}
