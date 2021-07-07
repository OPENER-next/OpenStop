import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';

// Screens
import 'screens/onboarding.dart';
import 'screens/home.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfiguration().loadFromAsset("config");

  runApp(HomeScreen());
}

