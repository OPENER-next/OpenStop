import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/models/difficulty_level.dart';


class PreferencesProvider extends ChangeNotifier {
  final SharedPreferences _preferences;
  static const ThemeMode _defaultThemeMode = ThemeMode.light;
  static const DifficultyLevel _defaultDifficulty = DifficultyLevel.easy;
  static const bool _defaultOnboarding = false;
  static const String _defaultTileTemplateServer = 'https://osm-2.nearest.place/retina/{z}/{x}/{y}.png';
  double _minZoom;
  double _maxZoom;

  PreferencesProvider({
    required SharedPreferences preferences,
    double minZoom = 0,
    double maxZoom = 18,
  }) : _preferences = preferences,
        _minZoom = minZoom,
        _maxZoom = maxZoom;


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

  String get tileTemplateServer {
    return _preferences.getString('tileTemplateServer') ?? _defaultTileTemplateServer;
  }

  set tileTemplateServer(String newTileTemplateServer) {
    if (newTileTemplateServer != tileTemplateServer) {
      _preferences.setString('tileTemplateServer', newTileTemplateServer);
      notifyListeners();
    }
  }

  double get minZoom => _minZoom;

  set minZoom(double value) {
    if (value != _minZoom) {
      _minZoom = value;
      notifyListeners();
    }
  }

  double get maxZoom => _maxZoom;

  set maxZoom(double value) {
    if (value != _maxZoom) {
      _maxZoom = value;
      notifyListeners();
    }
  }
}
