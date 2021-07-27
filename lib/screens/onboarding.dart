import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/widgets/dotsIndicator.dart';

// Screens
import 'home.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController(initialPage: 0);

  static const _dotsDuration = const Duration(milliseconds: 300);

  static const _dotsCurve = Curves.ease;

  _hasSeenOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 13,
            child: PageView(
              scrollDirection: Axis.horizontal,
              controller: _controller,
              children: <Widget>[
                Container(
                  color: Colors.redAccent,
                  child: Center(
                    child: Text('Introduction/ Purpose / How to Use'),
                  ),
                ),
                Container(
                    color: Colors.cyan,
                    child: Center(
                        child: Text('Legal Notice / Terms of Use / Privacy'))),
                Container(
                  color: Colors.yellow,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        _hasSeenOnboarding();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomeScreen()));
                      },
                      child: const Text('Get Started'),
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: new DotsIndicator(
              controller: _controller,
              itemCount: 3,
              onPageSelected: (int page) {
                _controller.animateToPage(
                  page,
                  duration: _dotsDuration,
                  curve: _dotsCurve,
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
