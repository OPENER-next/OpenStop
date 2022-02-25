import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/widgets/dots_indicator.dart';
import '/view_models/preferences_provider.dart';
import '/commons/screens.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {

  final _controller = PageController();
  final _background = TweenSequence(<TweenSequenceItem>[
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(
          begin: Colors.deepOrangeAccent.shade100,
          end: Colors.redAccent.shade100,
      ),
    ),
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(
          begin: Colors.redAccent.shade100,
          end: Colors.deepPurpleAccent.shade100,
      ),
    ),
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(
          begin: Colors.deepPurpleAccent.shade100,
          end: Colors.blueAccent.shade100,
      ),
    ),
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(
          begin: Colors.blueAccent.shade100,
          end: Colors.deepOrangeAccent.shade100,
      ),
    ),
  ]
  );


  _nextPage() {
    _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease
    );
  }

  @override
  Widget build(BuildContext context) {

    final List<Widget> pages = [
      OnboardingPage(
          image: 'assets/images/placeholder_image.png',
          title: 'Hey!',
          description: 'Wir freuen uns, dass du hier bist und deinen Teil zu einem besseren Nahverkehr beitragen willst.',
          buttonText: 'So funktioniert\'s',
          onButtonTap: _nextPage
      ),
      OnboardingPage(
          image: 'assets/images/placeholder_image.png',
          title: 'Schau\'s dir an!',
          description: 'Begib dich zu einer Haltestelle in deiner Umgebung, um ihren aktuellen Zustand zu erfassen.',
          buttonText: 'Okay, verstanden',
          onButtonTap: _nextPage
      ),
      OnboardingPage(
        image: 'assets/images/placeholder_image.png',
        title: 'Jetzt bist du gefragt!',
        description: 'Zur Erfassung wähle einen Marker in der App aus und beantworte die angezeigten Fragen.',
        buttonText: 'Is\' klar',
        onButtonTap: _nextPage,
      ),
      OnboardingPage(
          image: 'assets/images/placeholder_image.png',
          title: 'Sharing is caring',
          description: 'Lade deine Antworten auf OpenStreetMap hoch und stelle sie so der ganzen Welt zur Verfügung.',
          buttonText: 'Los geht\'s',
          onButtonTap: () {
            context.read<PreferencesProvider>().hasSeenOnboarding = true;
            Navigator.pushReplacementNamed(context, Screen.home);
          }
      ),
    ];

    return Scaffold(
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final color = _controller.hasClients ? _controller.page! / pages.length : .0;

            return DecoratedBox(
              decoration: BoxDecoration(
                color: _background.evaluate(AlwaysStoppedAnimation(color)),
              ),
              child: child,
            );
          },
          child: Column(
              children: [
                Expanded(
                  child: PageView(
                    scrollDirection: Axis.horizontal,
                    controller: _controller,
                    children: pages
                  ),
                ),
                Container(
                  height: 70,
                  margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom
                  ),
                  child: DotsIndicator(
                    controller: _controller,
                    itemCount: pages.length,
                    color: Colors.white,
                    onPageSelected: (int page) {
                      _controller.animateToPage(
                        page,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    },
                  ),
                ),
              ]
          ),
        )
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final String? buttonText;
  final IconData buttonIcon;
  final void Function()? onButtonTap;

  const OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
    this.buttonText,
    this.buttonIcon = Icons.chevron_right,
    this.onButtonTap,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(
          left: 40.0,
          top: MediaQuery.of(context).padding.top + 25,
          right: 40.0,
      ),
      child: Flex(
        direction: isPortrait ? Axis.vertical : Axis.horizontal,
        children: [
          Expanded(
            flex: 5,
            child: Image.asset(image,
            fit: BoxFit.contain),
          ),
          const Spacer(
            flex: 1
          ),
          Flexible(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  flex: 2,
                  child: Text(title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30.0,
                          fontWeight: FontWeight.w300
                      )
                  ),
                ),
                Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w300
                        ),
                      ),
                    )
                ),
                Spacer(
                    flex: buttonText != null ? 1 : 3
                ),
                if (buttonText != null)
                  Flexible(
                      flex: 2,
                      child: RawMaterialButton (
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(
                                color: Colors.white,
                                width: 1,
                                style: BorderStyle.solid
                            )
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 150,
                          minHeight: 36
                        ),
                        padding: const EdgeInsets.only(left: 14.0, right: 8.0),
                        elevation: 0.0,
                        highlightElevation: 0.0,
                        onPressed: onButtonTap,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        textStyle: const TextStyle(
                          color: Colors.white,
                        ),
                        child:Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(buttonText!),
                                Icon(buttonIcon),
                              ],
                            )
                      )
                  )
              ],
            ),
          ),
          if (!isPortrait)
            const Spacer(
              flex: 1
          )
        ],
      ),
    );
  }
}
