import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

// Screens
import 'screens/onboarding.dart';
import 'screens/home.dart';

bool hasSeenOnboarding;

Future <void> main() async{
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfiguration().loadFromAsset("config");

  SharedPreferences prefs = await SharedPreferences.getInstance();
  hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
  print('hasSeenOnboarding $hasSeenOnboarding');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OPENER next',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: hasSeenOnboarding ? HomeScreen() : OnboardingScreen(),
    );
  }
}