import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '/commons/themes.dart';
import '/commons/app_config.dart' as app_config;
import '/commons/screens.dart';
import '/view_models/preferences_provider.dart';

// Screens
import '/screens/about.dart';
import '/screens/home.dart';
import '/screens/licenses.dart';
import '/screens/onboarding.dart';
import '/screens/privacy_policy.dart';
import '/screens/settings.dart';
import '/utils/system_ui_adaptor.dart';


Future <void> main() async {
  // this is required to run flutter dependent code before runApp is called
  // in this case SharedPreferences requires this
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp(
    sharedPreferences: await SharedPreferences.getInstance()
  ));
}


class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;

  const MyApp({
    required this.sharedPreferences,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PreferencesProvider>(
      create: (_) => PreferencesProvider(
        preferences: sharedPreferences,
      ),
      builder: (context, child) {
        final themeMode = context.select<PreferencesProvider, ThemeMode>((preferences) => preferences.themeMode);
        // Using read to prevent unnecessary rebuilt
        final hasSeenOnboarding = context.read<PreferencesProvider>().hasSeenOnboarding;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: app_config.appName,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: const [
            Locale('de','DE')
          ],
          initialRoute: hasSeenOnboarding ? Screen.home : Screen.onboarding,
          routes: {
            Screen.home: (context) => const HomeScreen(),
            Screen.about: (context) => const AboutScreen(),
            Screen.licenses: (context) => const LicensesScreen(),
            Screen.onboarding: (context) => const OnboardingScreen(),
            Screen.privacyPolicy: (context) => const PrivacyPolicyScreen(),
            Screen.settings: (context) => const SettingsScreen()
          },
          navigatorObservers: [
            SystemUIAdaptor({
              Screen.home: SystemUIAdaptor.edgeToEdgeStyle,
              Screen.onboarding: SystemUIAdaptor.edgeToEdgeTransparentStyle,
            })
          ],
          theme: lightTheme,
          darkTheme: darkTheme,
          highContrastTheme: highContrastLightTheme,
          highContrastDarkTheme: highContrastDarkTheme,
          themeMode: themeMode,
        );
      },
    );
  }
}
