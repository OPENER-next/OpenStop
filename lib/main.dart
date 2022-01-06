import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final theme = context.select<PreferencesProvider, themeEnum>((preferences) => preferences.theme);
    final hasSeenOnboarding = context.select<PreferencesProvider, bool>((preferences) => preferences.onboarding);

    return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'OPENER next',
          theme: themeSelector(theme),
          home: hasSeenOnboarding ? const HomeScreen() : const OnboardingScreen(),
        );
  }
}
