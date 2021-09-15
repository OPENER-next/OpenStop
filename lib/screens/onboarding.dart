import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/widgets/dots_indicator.dart';

// Screens
import 'home.dart';
import 'terms_of_use.dart';
import 'privacy_policy.dart';

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
  void initState() {
    super.initState();
    // update native ui colors
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
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
                  color: Colors.yellow,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                            onPressed: () {
                            _hasSeenOnboarding();
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomeScreen())
                            );
                          },
                          child: const Text('Los geht\'s!'),
                      ),
                        ),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                          style: Theme.of(context).textTheme.caption,
                          children: <TextSpan>[
                            TextSpan(text: 'Mit dem Klick auf "Los geht\'s!", akzeptierst du unsere '),
                            TextSpan(
                                text: 'Nutzungsbedingungen',
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.secondary
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => TermsOfUse())
                                    );
                                  }),
                            TextSpan(text: ' und bestätigst, dass du unsere '),
                            TextSpan(
                                text: 'Datenschutzerklärung',
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.secondary
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => PrivacyPolicy())
                                    );
                                  }),
                            TextSpan(text: ' gelesen hast.'),
                            ],
                          ),
                        ),
                      ],
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
              itemCount: 2,
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
