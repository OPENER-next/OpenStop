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
  // Ideally has to match the number of pages
  final _colorArray = <Color>[
    Colors.deepOrangeAccent.shade100,
    Colors.redAccent.shade100,
    Colors.deepPurpleAccent.shade100,
    Colors.blueAccent.shade100,
  ];
  late final _background = _buildColorSequence(_colorArray);

  TweenSequence<Color?> _buildColorSequence(List<Color> colors) {
    assert(colors.isNotEmpty, 'Colors must not be empty');
    return TweenSequence(
        List.generate(
            colors.length == 1 ? colors.length : colors.length - 1,
                (index) =>
                TweenSequenceItem(
                    weight: 1.0,
                    tween: ColorTween(
                        begin: colors[index],
                        end: colors[colors.length == 1 ? index : index + 1]
                    )
                )
        )
    );
  }

  _nextPage() {
    _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease
    );
  }

  @override
  Widget build(BuildContext context) {

    final pages = [
      OnboardingPage(
          image: 'assets/images/placeholder_image.png',
          title: 'Hey!',
          description: 'Wir freuen uns, dass du hier bist und deinen Teil zu einem besseren Nahverkehr beitragen willst.',
          buttonText: 'So funktioniert\'s',
          onButtonTap: _nextPage
      ),
      OnboardingPage(
          image: 'assets/images/placeholder_image.png',
          title: 'Schau\'s dir an',
          description: 'Begib dich zu einer Haltestelle in deiner Umgebung, um ihren aktuellen Zustand zu erfassen.',
          buttonText: 'Mach\' ich',
          onButtonTap: _nextPage
      ),
      OnboardingPage(
        image: 'assets/images/placeholder_image.png',
        title: 'Jetzt bist du gefragt',
        description: 'Wähle zur Erfassung einen Marker in der App aus und beantworte die angezeigten Fragen.',
        buttonText: 'Okay, verstanden',
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
            final color = _controller.hasClients && pages.length > 1 ? _controller.page! / (pages.length - 1) : 0.0;

            return ColoredBox(
              color: _background.evaluate(AlwaysStoppedAnimation(color))!,
              child: child,
            );
          },
          child: Column(
              children: [
                Expanded(
                  child: PageView(
                    scrollBehavior: const ScrollBehavior().copyWith(overscroll: false),
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
                      child: Theme(
                        data: ThemeData(
                            outlinedButtonTheme: OutlinedButtonThemeData(
                              style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  primary: Colors.white,
                                  minimumSize: const Size(150, 36),
                                  elevation: 0.0,
                                  padding: const EdgeInsets.only(left: 14.0, right: 8.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  side: const BorderSide(
                                      style: BorderStyle.solid,
                                      color: Colors.white
                                  ),
                                  textStyle: const TextStyle(
                                      fontWeight: FontWeight.w400
                                  )
                              )
                            )
                        ),
                        child: OutlinedButton(
                            onPressed: onButtonTap,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(buttonText!),
                                Icon(buttonIcon),
                              ],
                            )
                        ),
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
