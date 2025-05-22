import 'package:flutter/material.dart';
import 'package:flutter_mvvm_architecture/base.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// An interface around [SharedPreferences] with observable properties.

class PreferencesService extends Service {
  final SharedPreferences _preferences;
  static const _defaultThemeMode = ThemeMode.system;
  static const _defaultProfessional = false;
  static const _defaultOnboarding = false;
  static const _defaultMapLocation = LatLng(50.8144951, 12.9295576);
  static const _defaultMapZoom = 15.0;
  static const _defaultMapRotation = 0.0;

  PreferencesService({
    required SharedPreferences preferences,
  }) : _preferences = preferences;

  final _hasSeenOnboardingAtom = Atom(name: 'hasSeenOnboardingPreference');
  bool get hasSeenOnboarding {
    _hasSeenOnboardingAtom.reportRead();
    return _preferences.getBool('hasSeenOnboarding') ?? _defaultOnboarding;
  }

  set hasSeenOnboarding(bool newValue) {
    _hasSeenOnboardingAtom.reportWrite<bool>(
      newValue,
      hasSeenOnboarding,
      () => _preferences.setBool('hasSeenOnboarding', newValue),
    );
  }

  final _themeModeIndexAtom = Atom(name: 'themePreference');
  ThemeMode get themeMode {
    _themeModeIndexAtom.reportRead();
    final themeModeIndex = _preferences.getInt('theme');
    return themeModeIndex != null && themeModeIndex < ThemeMode.values.length
        ? ThemeMode.values[themeModeIndex]
        : _defaultThemeMode;
  }

  set themeMode(ThemeMode newThemeMode) {
    _themeModeIndexAtom.reportWrite<ThemeMode>(
      newThemeMode,
      themeMode,
      () => _preferences.setInt('theme', newThemeMode.index),
    );
  }

  final _isProfessionalAtom = Atom(name: 'isProfessionalPreference');
  bool get isProfessional {
    _isProfessionalAtom.reportRead();
    return _preferences.getBool('isProfessional') ?? _defaultProfessional;
  }

  set isProfessional(bool newValue) {
    _isProfessionalAtom.reportWrite<bool>(
      newValue,
      isProfessional,
      () => _preferences.setBool('isProfessional', newValue),
    );
  }

  final _mapLocationAtom = Atom(name: 'mapLocationPreference');
  LatLng get mapLocation {
    _mapLocationAtom.reportRead();
    final lat = _preferences.getDouble('mapLocationLat');
    final lon = _preferences.getDouble('mapLocationLon');
    return lat != null && lon != null ? LatLng(lat, lon) : _defaultMapLocation;
  }

  set mapLocation(LatLng newValue) {
    _mapLocationAtom.reportWrite<LatLng>(
      newValue,
      mapLocation,
      () {
        _preferences.setDouble('mapLocationLat', newValue.latitude);
        _preferences.setDouble('mapLocationLon', newValue.longitude);
      },
    );
  }

  final _mapZoomAtom = Atom(name: 'mapZoomPreference');
  double get mapZoom {
    _mapZoomAtom.reportRead();
    return _preferences.getDouble('mapZoom') ?? _defaultMapZoom;
  }

  set mapZoom(double newValue) {
    _mapZoomAtom.reportWrite<double>(
      newValue,
      mapZoom,
      () => _preferences.setDouble('mapZoom', newValue),
    );
  }

  final _mapRotationAtom = Atom(name: 'mapRotationPreference');
  double get mapRotation {
    _mapRotationAtom.reportRead();
    return _preferences.getDouble('mapRotation') ?? _defaultMapRotation;
  }

  set mapRotation(double newValue) {
    _mapRotationAtom.reportWrite<double>(
      newValue,
      mapRotation,
      () => _preferences.setDouble('mapRotation', newValue),
    );
  }
}
