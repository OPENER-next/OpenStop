import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/commons/themes.dart';
import '/commons/app_config.dart' as app_config;
import '/view_models/preferences_provider.dart';

// Screens
import '/commons/routes.dart';


Future <void> main() async {
  // this is required to run flutter dependent code before runApp is called
  // in this case SharedPreferences requires this
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

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
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          // used instead of home: because otherwise no pop page transition to the first screen will be applied
          onGenerateRoute: (settings) => hasSeenOnboarding ? Routes.home : Routes.onboarding,
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
