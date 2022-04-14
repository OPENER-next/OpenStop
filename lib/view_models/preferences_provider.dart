import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/models/difficulty_level.dart';
import '/commons/tile_layers.dart';


class PreferencesProvider extends ChangeNotifier {
  final SharedPreferences _preferences;
  static const _defaultThemeMode = ThemeMode.system;
  static const _defaultDifficulty = DifficultyLevel.easy;
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

  DifficultyLevel get difficulty{
    final difficultyIndex = _preferences.getInt('difficulty');
    return difficultyIndex != null && difficultyIndex < DifficultyLevel.values.length
        ? DifficultyLevel.values[difficultyIndex]
        : _defaultDifficulty;
  }

  set difficulty(DifficultyLevel newDifficulty){
    if (newDifficulty != difficulty) {
      _preferences.setInt('difficulty', newDifficulty.index);
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
