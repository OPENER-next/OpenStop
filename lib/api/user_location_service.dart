// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_mvvm_architecture/base.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';

class UserLocationService extends Service implements Disposable {

  final _state = Observable(LocationTrackingState.disabled);

  /// Whether the location permission has been granted and the location service has been enabled or not.
  /// This only changes after calls to [startTracking] since there is no permission notification API.
  /// Pending means that the tracking has been requested, but at this point
  /// it's unclear if the user grants the permissions or enables the location service.

  LocationTrackingState get state => _state.value;

  final _position = Observable<Position?>(null);

  /// The last known position if any.

  Position? get position => _position.value;

  final _shouldFollowLocation = Observable(false);

  /// Whether the camera should follow the user's position or not.

  bool get shouldFollowLocation => _shouldFollowLocation.value;

  set shouldFollowLocation(bool value) {
    _shouldFollowLocation.value = value;
  }

  late final _isFollowingLocation = Computed(
    () => shouldFollowLocation && state == LocationTrackingState.enabled,
  );

  /// Whether the location service is enabled and the location should be followed.

  bool get isFollowingLocation => _isFollowingLocation.value;


  final LocationSettings _locationSettings;

  StreamSubscription<Position>? _positionNotifierStreamSub;

  StreamSubscription<ServiceStatus>? _serviceStatusStreamSub;

  UserLocationService({
    Duration updateInterval = const Duration(milliseconds: 300),
    int distanceThreshold = 1,
  }) : _locationSettings = AndroidSettings(
    intervalDuration: updateInterval,
    distanceFilter: distanceThreshold
  ), super();


  /// This function will automatically request permissions and the activation of the location service.

  void startLocationTracking() async {
    if (_state.value != LocationTrackingState.disabled) return;

    runInAction(() => _state.value = LocationTrackingState.pending);

    // request permissions and get last known position
    final lastPosition = await _acquireUserLocation(false);

    runInAction(() {
      // if location was successfully granted and retrieved
      // and if state is still pending which means it wasn't canceled during the process
      if (lastPosition != null && _state.value == LocationTrackingState.pending) {
        // move to last known location if available
        _position.value = lastPosition;

        _positionNotifierStreamSub = Geolocator.getPositionStream(
          locationSettings: _locationSettings
        ).listen(
          (p) => runInAction(() => _position.value = p),
          onError: (e) => stopLocationTracking(),
        );

        try {
          _serviceStatusStreamSub = Geolocator.getServiceStatusStream().listen(_handleServiceStatus);
        }
        on UnimplementedError {
          // getServiceStatusStream is not supported on web
        }
        _state.value = LocationTrackingState.enabled;
      }
      else {
        _state.value = LocationTrackingState.disabled;
      }
    });
  }


  late final stopLocationTracking = Action(() {
    if (_state.value == LocationTrackingState.disabled) return;

    _positionNotifierStreamSub?.cancel();
    _serviceStatusStreamSub?.cancel();

    _state.value = LocationTrackingState.disabled;
  });


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
  FutureOr onDispose() {
    _positionNotifierStreamSub?.cancel();
    _serviceStatusStreamSub?.cancel();
  }
}

/// Pending means that the tracking has been requested, but at this point
/// it's unclear if the user grants the permissions or enables the location service.

enum LocationTrackingState {
  pending,
  enabled,
  disabled
}
