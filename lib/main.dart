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
    return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'OPENER next',
          theme: themeSelector(context.select<PreferencesProvider, themeEnum>((preference) => preference.theme)),
          home: context.select<PreferencesProvider, bool>((preference) => preference.onboarding) ? const HomeScreen() : const OnboardingScreen(),
        );
  }
}
