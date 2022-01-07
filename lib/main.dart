import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/commons/themes.dart';
import '/view_models/preferences_provider.dart';

// Screens
import 'screens/onboarding.dart';
import 'screens/home.dart';


Future <void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(ChangeNotifierProvider<PreferencesProvider>(
    create: (_) => PreferencesProvider(
        preferences: prefs,
    ),
    child: const MyApp(),
  ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<PreferencesProvider, ThemeMode>((preferences) => preferences.themeMode);
    final hasSeenOnboarding = context.select<PreferencesProvider, bool>((preferences) => preferences.hasSeenOnboarding);

    return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'OPENER next',
          theme: lightTheme,
          darkTheme: darkTheme,
          highContrastTheme: highContrastLightTheme,
          highContrastDarkTheme: highContrastDarkTheme,
          themeMode: themeMode,
          home: hasSeenOnboarding ? const HomeScreen() : const OnboardingScreen(),
        );
  }
}
