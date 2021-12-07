import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Screens
import 'screens/onboarding.dart';
import 'screens/home.dart';

import 'commons/themes.dart';

bool hasSeenOnboarding = false;

Future <void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
  debugPrint('hasSeenOnboarding $hasSeenOnboarding');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OPENER next',
      theme: appTheme,
      home: hasSeenOnboarding ? const HomeScreen() : const OnboardingScreen(),
    );
  }
}
