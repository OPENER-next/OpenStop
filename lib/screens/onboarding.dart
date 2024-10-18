import 'package:flutter/material.dart' hide View;
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_mvvm_architecture/base.dart';

import '/commons/routes.dart';
import '/view_models/onboarding_view_model.dart';
import '/widgets/dots_indicator.dart';


class OnboardingScreen extends View<OnboardingViewModel> {
  const OnboardingScreen({super.key}) : super(create: OnboardingViewModel.new);

  // Ideally has to match the number of pages
  static final _colorArray = <Color>[
    Colors.blueAccent.shade100,
    Colors.deepPurpleAccent.shade100,
    Colors.purpleAccent.shade100,
    Colors.redAccent.shade100,
  ];

  static TweenSequence<Color?> _buildColorSequence(List<Color> colors) {
    assert(colors.isNotEmpty, 'Colors must not be empty');
    return TweenSequence(
      List.generate(
        colors.length == 1 ? colors.length : colors.length - 1,
        (index) => TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(
            begin: colors[index],
            end: colors[colors.length == 1 ? index : index + 1],
          ),
        ),
      ),
    );
  }

  static final _backgroundColorSequence = _buildColorSequence(_colorArray);

  @override
  Widget build(BuildContext context, viewModel) {
    final appLocale = AppLocalizations.of(context)!;
    final pages = [
      OnboardingPage(
        image: 'assets/images/onboarding/onboarding_1.png',
        title: appLocale.onboardingGreetingTitle,
        description: appLocale.onboardingGreetingDescription,
        buttonText: appLocale.onboardingGreetingButton,
        onButtonTap: viewModel.nextPage,
      ),
      OnboardingPage(
        image: 'assets/images/onboarding/onboarding_2.png',
        title: appLocale.onboardingSurveyingTitle,
        description: appLocale.onboardingSurveyingDescription,
        buttonText: appLocale.onboardingSurveyingButton,
        onButtonTap: viewModel.nextPage,
      ),
      OnboardingPage(
        image: 'assets/images/onboarding/onboarding_3.png',
        title: appLocale.onboardingAnsweringTitle,
        description: appLocale.onboardingAnsweringDescription,
        buttonText: appLocale.onboardingAnsweringButton,
        onButtonTap: viewModel.nextPage,
      ),
      OnboardingPage(
        image: 'assets/images/onboarding/onboarding_4.png',
        title: appLocale.onboardingContributingTitle,
        description: appLocale.onboardingContributingDescription,
        buttonText: appLocale.onboardingContributingButton,
        onButtonTap: () {
          viewModel.markOnboardingAsSeen();
          // remove previous routes to start of with no duplicated home screen
          // when re-visiting the onboarding screen
          Navigator.of(context).pushAndRemoveUntil(Routes.home, (route) => false);
        },
      ),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Theme(
        data: ThemeData(
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              minimumSize: const Size(150, 36),
              elevation: 0.0,
              padding: const EdgeInsets.only(left: 14.0, right: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              side: const BorderSide(
                style: BorderStyle.solid,
                color: Colors.white,
              ),
              textStyle: const TextStyle(
                fontSize: 16.0,
              ),
            ),
          ),
        ),
        child: Scaffold(
          body: AnimatedBuilder(
            animation: viewModel.controller,
            builder: (context, child) {
              final color = viewModel.controller.hasClients && pages.length > 1 ? viewModel.controller.page! / (pages.length - 1) : 0.0;

              return ColoredBox(
                color: _backgroundColorSequence.evaluate(AlwaysStoppedAnimation(color))!,
                child: child,
              );
            },
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: PageView(
                      scrollBehavior: const ScrollBehavior().copyWith(overscroll: false),
                      scrollDirection: Axis.horizontal,
                      controller: viewModel.controller,
                      physics: const ClampingScrollPhysics(),
                      allowImplicitScrolling: true,
                      children: pages,
                    ),
                  ),
                  Container(
                    height: 70,
                    margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom
                    ),
                    child: DotsIndicator(
                      controller: viewModel.controller,
                      itemCount: pages.length,
                      color: Colors.white,
                      onPageSelected: (int page) {
                        viewModel.controller.animateToPage(
                          page,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Flex(
      direction: isPortrait ? Axis.vertical : Axis.horizontal,
      children: [
        if (!isPortrait) const Spacer(
          flex: 1,
        ),
        Image.asset(image,
          fit: BoxFit.fitWidth,
        ),
        Flexible(
          flex: 12,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 40.0,
              right: 40.0,
            ),
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
                      fontWeight: FontWeight.w300,
                    ),
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
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
                Spacer(
                  flex: buttonText != null ? 1 : 3
                ),
                if (buttonText != null) Flexible(
                  flex: 2,
                  child: OutlinedButton(
                    onPressed: onButtonTap,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(buttonText!),
                        Icon(buttonIcon),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isPortrait) const Spacer(
          flex: 1,
        ),
      ],
    );
  }
}
