import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/commons/tile_layers.dart';


class PreferencesProvider extends ChangeNotifier {
  final SharedPreferences _preferences;
  static const _defaultThemeMode = ThemeMode.system;
  static const _defaultProfessional = false;
  static const _defaultOnboarding = false;
  static const _defaultTileLayerId = TileLayerId.standard;
  static final _defaultMapLocation = LatLng(50.8144951, 12.9295576);
  static const _defaultMapZoom = 15.0;
  static const _defaultMapRotation = 0.0;

  PreferencesProvider({
    required SharedPreferences preferences,
  }) : _preferences = preferences;


  bool get hasSeenOnboarding {
    return _preferences.getBool('hasSeenOnboarding') ?? _defaultOnboarding;
  }

  set hasSeenOnboarding(bool newValue) {
    if (newValue != hasSeenOnboarding) {
      _preferences.setBool('hasSeenOnboarding', newValue);
      notifyListeners();
    }
  }

  ThemeMode get themeMode {
    final themeModeIndex = _preferences.getInt('theme');
    return themeModeIndex != null && themeModeIndex < ThemeMode.values.length
        ? ThemeMode.values[themeModeIndex]
        : _defaultThemeMode;
  }

  set themeMode(ThemeMode newThemeMode) {
    if (newThemeMode != themeMode) {
      _preferences.setInt('theme', newThemeMode.index);
      notifyListeners();
    }
  }

  bool get isProfessional {
    return _preferences.getBool('isProfessional') ?? _defaultProfessional;
  }

  set isProfessional(bool newValue) {
    if (newValue != isProfessional) {
      _preferences.setBool('isProfessional', newValue);
      notifyListeners();
    }
  }

  TileLayerId get tileLayerId {
    final tileLayerIdIndex = _preferences.getInt('tileLayerId');
    return tileLayerIdIndex != null && tileLayerIdIndex < TileLayerId.values.length
        ? TileLayerId.values[tileLayerIdIndex]
        : _defaultTileLayerId;
  }

  set tileLayerId(TileLayerId newTileLayerId) {
    if (newTileLayerId != tileLayerId) {
      _preferences.setInt('tileLayerId', newTileLayerId.index);
      notifyListeners();
    }
  }

  LatLng get mapLocation {
    final lat = _preferences.getDouble('mapLocationLat');
    final lon = _preferences.getDouble('mapLocationLon');
    return lat != null && lon != null ? LatLng(lat, lon) : _defaultMapLocation;
  }

  set mapLocation(LatLng newValue) {
    if (newValue != mapLocation) {
      _preferences.setDouble('mapLocationLat', newValue.latitude);
      _preferences.setDouble('mapLocationLon', newValue.longitude);
      notifyListeners();
    }
  }

  double get mapZoom {
    return _preferences.getDouble('mapZoom') ?? _defaultMapZoom;
  }

  set mapZoom(double newValue) {
    if (newValue != mapZoom) {
      _preferences.setDouble('mapZoom', newValue);
      notifyListeners();
    }
  }

  double get mapRotation {
    return _preferences.getDouble('mapRotation') ?? _defaultMapRotation;
  }

  set mapRotation(double newValue) {
    if (newValue != mapRotation) {
      _preferences.setDouble('mapRotation', newValue);
      notifyListeners();
    }
  }
}
