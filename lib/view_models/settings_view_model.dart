// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart' hide Action;
import 'package:flutter_mvvm_architecture/base.dart';
import 'package:mobx/mobx.dart';

import '/api/preferences_service.dart';

class SettingsViewModel extends ViewModel {

  PreferencesService get _preferencesService => getService<PreferencesService>();

  ThemeMode get themeMode => _preferencesService.themeMode;

  bool get isProfessional => _preferencesService.isProfessional;

  late final changeThemeMode = Action((ThemeMode value) {
    _preferencesService.themeMode = value;
  });

  late final changeIsProfessional = Action((bool value) {
    _preferencesService.isProfessional = value;
  });
}
