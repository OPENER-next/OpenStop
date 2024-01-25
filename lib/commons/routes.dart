// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '/widgets/hero_viewer.dart';
import '/screens/about.dart';
import '/screens/help.dart';
import '/screens/home.dart';
import '/screens/licenses.dart';
import '/screens/onboarding.dart';
import '/screens/privacy_policy.dart';
import '/screens/settings.dart';

class Routes {
  static SlideInOutPageRoute get about => SlideInOutPageRoute(
      const AboutScreen()
  );
  static SlideInOutPageRoute get help => SlideInOutPageRoute(
      const HelpScreen()
  );
  static SlideInOutPageRoute get home => SlideInOutPageRoute(
    const HomeScreen()
  );
  static SlideInOutPageRoute get licenses => SlideInOutPageRoute(
    const LicensesScreen()
  );
  static SlideInOutPageRoute get onboarding => SlideInOutPageRoute(
    const OnboardingScreen()
  );
  static SlideInOutPageRoute get privacyPolicy => SlideInOutPageRoute(
    const PrivacyPolicyScreen()
  );
  static SlideInOutPageRoute get settings => SlideInOutPageRoute(
    const SettingsScreen()
  );
}


abstract class WidgetPageRoute<T> extends PageRoute<T> {
  Widget get page;

  WidgetPageRoute({
    RouteSettings? settings,
    bool fullscreenDialog = false
  }): super(settings: settings, fullscreenDialog: fullscreenDialog);
}


/// A page transition builder with push and pop animation
/// on push: slides the page from right (off screen) to left
/// on pop: slides the page from left to right (off screen)
/// This won't animate for HeroViewerRoute animations

class SlideInOutPageRoute<T> extends WidgetPageRoute<T> {
  @override
  final Widget page;

  SlideInOutPageRoute(this.page, {
    RouteSettings? settings,
    bool fullscreenDialog = false,
  }) : super(settings: settings, fullscreenDialog: fullscreenDialog);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return page;
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic
      )),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-1, 0),
        ).animate(CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic
        )),
        child: child,
      ),
    );
  }

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute)
    => nextRoute is PageRoute && nextRoute is! HeroViewerRoute;

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute)
    => previousRoute is PageRoute && previousRoute is! HeroViewerRoute;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);
}
