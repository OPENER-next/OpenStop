import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Screens
import 'home.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController(initialPage: 0);

  _hasSeenOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PageView(
      scrollDirection: Axis.horizontal,
      controller: _controller,
      children: <Widget>[
        Center(
          child: Text('First Page'),
        ),
        Center(
          child: Text('Second Page'),
        ),
        Center(
          child: Center(
            child: ElevatedButton(
              onPressed: () {
                _hasSeenOnboarding();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(
                        builder: (context) => HomeScreen()));
              },
              child: const Text('Get Started'),
            ),
          ),
        )
      ],
    ));
  }
}
