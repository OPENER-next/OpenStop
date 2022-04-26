import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/commons/routes.dart';


/// A flutter route observer used to adjust the system ui style based on the active page.
/// This class provides the predefined callbacks [topAndBottomBarStyle] and [edgeToEdgeStyle].

class SystemUIAdaptor extends RouteObserver<PageRoute<dynamic>> {

  /// A map of route widgets with a corresponding callback function each, which can be used to change the system ui style.

  final Map<Type, void Function(BuildContext)> systemStyleMap;

  /// The default system style callback that is used if none was specified in the [systemStyleMap].

  final void Function(BuildContext) defaultStyleCallback;

  SystemUIAdaptor(
    this.systemStyleMap,
    { this.defaultStyleCallback = topAndBottomBarStyle }
  );

  /// Top and bottom bar system style is defined as follows:
  /// - transparent top bar so it takes the header color
  /// - bottom navigation bar takes theme scaffold background color

  static void topAndBottomBarStyle(BuildContext context) {
    // show top and bottom bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    // update native ui colors
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false
    ));
  }

  /// Edge to edge system style is defined as follows:
  /// - Widgets can grow to the edge of the screen and lie behind the top and bottom bar
  /// - semi transparent top and bottom bar

  static void edgeToEdgeStyle(BuildContext context) {
    // set system ui to fullscreen
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    // update native ui colors
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.black.withOpacity(0.25),
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black.withOpacity(0.25),
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: false
    ));
  }


  /// Edge to edge system style is defined as follows:
  /// - Widgets can grow to the edge of the screen and lie behind the top and bottom bar
  /// - transparent top and bottom bar

  static void edgeToEdgeTransparentStyle(BuildContext context) {
    // set system ui to fullscreen
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]
    );
    // update native ui colors
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: false
    ));
  }


  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is WidgetPageRoute) {
      _callStyleCallback(route);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute is WidgetPageRoute) {
      _callStyleCallback(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute is WidgetPageRoute && route is WidgetPageRoute) {
      _callStyleCallback(previousRoute);
    }
  }


  void _callStyleCallback(WidgetPageRoute<dynamic> route) {
    final context = route.navigator?.context;
    if (context != null) {
      final systemStyleCallback = systemStyleMap[route.page.runtimeType];
      if (systemStyleCallback != null) {
        systemStyleCallback.call(context);
      }
      else {
        defaultStyleCallback(context);
      }
    }
  }
}
