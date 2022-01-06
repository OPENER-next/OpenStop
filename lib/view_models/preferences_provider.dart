import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/models/difficulty_level.dart';
import '/models/theme_identifier.dart';


class PreferencesProvider extends ChangeNotifier {
  final SharedPreferences _preferences;
  static const ThemeIdentifier _defaultTheme = ThemeIdentifier.light;
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

  ThemeIdentifier get theme {
    final themeIndex = _preferences.getInt('theme');
    return themeIndex != null && themeIndex < ThemeIdentifier.values.length
        ? ThemeIdentifier.values[themeIndex]
        : _defaultTheme;
  }

  set theme(ThemeIdentifier newTheme) {
    if (newTheme != theme) {
      _preferences.setInt('theme', newTheme.index);
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
