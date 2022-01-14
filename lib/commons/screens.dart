// do not use slashes for the route names, because this will be treated as a deep link
// and therefore cause all sub widgets to be pre-build/created
// see: https://api.flutter.dev/flutter/widgets/Navigator/defaultGenerateInitialRoutes.html
// or: https://medium.com/codechai/dont-use-to-prefix-your-routes-in-flutter-f3844ce1fdd5

class Screen {
  static const String home = '/';
  static const String about = 'about';
  static const String licenses = 'licenses';
  static const String onboarding = 'onboarding';
  static const String privacyPolicy = 'privacyPolicy';
  static const String settings = 'settings';
  static const String termsOfUse = 'termsOfUse';
}
