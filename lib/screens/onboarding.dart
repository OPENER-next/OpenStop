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

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();

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
          backgroundColor: Colors.deepOrangeAccent.shade100,
          buttonText: 'So funktioniert\'s',
          onButtonTap: _nextPage
      ),
      OnboardingPage(
          image: 'assets/images/placeholder_image.png',
          title: 'Schau\'s dir an!',
          description: 'Begib dich zu einer Haltestelle in deiner Umgebung, um ihren aktuellen Zustand zu erfassen.',
          backgroundColor: Colors.redAccent.shade100,
          buttonText: 'Okay, verstanden',
          onButtonTap: _nextPage
      ),
      OnboardingPage(
        image: 'assets/images/placeholder_image.png',
        title: 'Jetzt bist du gefragt!',
        description: 'Zur Erfassung wähle einen Marker in der App aus und beantworte die angezeigten Fragen.',
        backgroundColor: Colors.deepPurpleAccent.shade100,
        buttonText: 'Is\' klar',
        onButtonTap: _nextPage,
      ),
      OnboardingPage(
          image: 'assets/images/placeholder_image.png',
          title: 'Sharing is caring',
          description: 'Lade deine Antworten auf OpenStreetMap hoch und stelle sie so der ganzen Welt zur Verfügung.',
          backgroundColor: Colors.blueAccent.shade100,
          buttonText: 'Los geht\'s',
          onButtonTap: () {
            context.read<PreferencesProvider>().hasSeenOnboarding = true;
            Navigator.pushReplacementNamed(context, Screen.home);
          }
      ),
    ];

    return Scaffold(
        body: Stack(
          alignment: Alignment.bottomCenter,
            children: [
              PageView(
                scrollDirection: Axis.horizontal,
                controller: _controller,
                children: pages
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
        )
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final Color? backgroundColor;
  final String? buttonText;
  final IconData buttonIcon;
  final void Function()? onButtonTap;

  const OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
    this.backgroundColor = Colors.transparent,
    this.buttonText,
    this.buttonIcon = Icons.keyboard_arrow_right,
    this.onButtonTap,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Container(
      color: backgroundColor,
      padding: EdgeInsets.only(
          left: 40.0,
          top: MediaQuery.of(context).padding.top + 25,
          right: 40.0,
          /// +70 so the it never overlays DotIndicator
          bottom: MediaQuery.of(context).padding.bottom + 70
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
            child: Flex(
              direction: Axis.vertical,
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
                const Spacer(
                    flex: 1
                ),
                if (buttonText != null)
                  Flexible(
                      flex: 2,
                      child: IntrinsicWidth(
                        child: RawMaterialButton (
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(
                                  color: Colors.white,
                                  width: 1,
                                  style: BorderStyle.solid
                              )
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 14.0),
                          elevation: 0.0,
                          highlightElevation: 0.0,
                          onPressed: onButtonTap,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          textStyle: const TextStyle(
                            color: Colors.white,
                          ),
                          child:Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(buttonText!),
                                  Icon(buttonIcon)
                                ],
                              )
                        ),
                      )
                  )
                else
                  const Spacer(
                      flex: 2
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
