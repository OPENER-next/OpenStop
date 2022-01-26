import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';

import '/widgets/dots_indicator.dart';
import '/view_models/preferences_provider.dart';
import '/commons/screens.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              scrollDirection: Axis.horizontal,
              controller: _controller,
              children: <Widget>[
                Container(
                  color: Colors.redAccent,
                  child: const Center(
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
                              context.read<PreferencesProvider>().hasSeenOnboarding = true;
                              Navigator.pushReplacementNamed(context, Screen.home);
                          },
                          child: const Text('Los geht\'s!'),
                      ),
                        ),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                          style: Theme.of(context).textTheme.caption,
                          children: <TextSpan>[
                            const TextSpan(text: 'Mit dem Klick auf "Los geht\'s!", akzeptierst du unsere '),
                            TextSpan(
                                text: 'Nutzungsbedingungen',
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.secondary
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => Navigator.pushNamed(context, Screen.termsOfUse),
                            ),
                            const TextSpan(text: ' und bestätigst, dass du unsere '),
                            TextSpan(
                                text: 'Datenschutzerklärung',
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.secondary
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => Navigator.pushNamed(context, Screen.privacyPolicy),
                            ),
                            const TextSpan(text: ' gelesen hast.'),
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: DotsIndicator(
              controller: _controller,
              itemCount: 2,
              onPageSelected: (int page) {
                _controller.animateToPage(
                  page,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
