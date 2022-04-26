import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '/commons/themes.dart';
import '/commons/app_config.dart' as app_config;
import '/view_models/preferences_provider.dart';

// Screens
import '/utils/system_ui_adaptor.dart';
import '/commons/routes.dart';
import '/screens/home.dart';
import '/screens/onboarding.dart';


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
          // used instead of home: because otherwise the navigatorObservers won't get called
          // also otherwise no pop page transition to the first screen will be applied
          onGenerateRoute: (settings) => hasSeenOnboarding ? Routes.home : Routes.onboarding,
          navigatorObservers: [
            SystemUIAdaptor({
              HomeScreen: SystemUIAdaptor.edgeToEdgeStyle,
              OnboardingScreen: SystemUIAdaptor.edgeToEdgeTransparentStyle,
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
