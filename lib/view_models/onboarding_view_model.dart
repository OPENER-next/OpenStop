// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/widgets.dart' hide Action;
import 'package:flutter_mvvm_architecture/base.dart';
import 'package:mobx/mobx.dart';

import '/api/preferences_service.dart';

class OnboardingViewModel extends ViewModel {

  PreferencesService get _preferencesService => getService<PreferencesService>();

  late final markOnboardingAsSeen = Action(() {
    _preferencesService.hasSeenOnboarding = true;
  });

  final controller = PageController();

  void nextPage() {
    controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }
}
