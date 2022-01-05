import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/commons/themes.dart';


abstract class DifficultyLevels {
  static const int easy = 1;
  static const int standard = 2;
  static const int hard = 3;
}

enum difficultyEnum {
  easy, standard, hard
}

enum themeEnum {
  light, dark, contrast
}

ThemeData themeSelector (themeEnum theme) {
  switch (theme) {
    case themeEnum.dark:
      return darkTheme;
    case themeEnum.contrast:
      return darkTheme;
    case themeEnum.light:
    default:
      return lightTheme;
  }
}

class PreferencesProvider extends ChangeNotifier {
  final SharedPreferences _preferences;
  final themeEnum _defaultTheme = themeEnum.light;
  final int _defaultDifficulty = DifficultyLevels.easy;
  final bool _defaultOnboarding = false;
  final String _defaultTileTemplateServer = 'https://osm-2.nearest.place/retina/{z}/{x}/{y}.png';
  double _minZoom;
  double _maxZoom;

  PreferencesProvider({
    required SharedPreferences preferences,
    double minZoom = 0,
    double maxZoom = 18,
  }) : _preferences = preferences,
        _minZoom = minZoom,
        _maxZoom = maxZoom;


  bool get onboarding {
    return _preferences.getBool('hasSeenOnboarding') ?? _defaultOnboarding;
  }

  set onboarding(bool newValue) {
    if (newValue != onboarding) {
      _preferences.setBool('hasSeenOnboarding', newValue);
      notifyListeners();
    }
  }

  themeEnum get theme {
    return themeEnum.values[_preferences.getInt('theme') ?? _defaultTheme.index];
  }

  set theme(themeEnum newTheme) {
    if (newTheme != theme) {
      _preferences.setInt('theme', newTheme.index);
      notifyListeners();
    }
  }

  int get difficulty{
    return _preferences.getInt('difficulty') ?? _defaultDifficulty;
  }

  set difficulty(int newDifficulty){
    if (newDifficulty != difficulty) {
      _preferences.setInt('difficulty', newDifficulty);
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
