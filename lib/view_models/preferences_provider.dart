import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/commons/tile_layers.dart';


class PreferencesProvider extends ChangeNotifier {
  final SharedPreferences _preferences;
  static const _defaultThemeMode = ThemeMode.system;
  static const _defaultProfessional = false;
  static const _defaultOnboarding = false;
  static const _defaultTileLayerId = TileLayerId.standard;

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
}
