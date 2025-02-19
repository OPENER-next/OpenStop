// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get aboutTitle => 'درباره ما';

  @override
  String get aboutSlogan => 'توقف بعدی: دسترس‌پذیری';

  @override
  String get aboutVersionLabel => 'نگارش';

  @override
  String get aboutAuthorsLabel => 'توسعه‌دهندگان';

  @override
  String aboutAuthorsDescription(String appName) {
    return '$appName مشارکت کنندگان';
  }

  @override
  String get aboutPrivacyPolicyLabel => 'سیاست حفظ حریم خصوصی';

  @override
  String get aboutIdeaLabel => 'ایده';

  @override
  String get aboutIdeaDescription => 'دانشگاه فناوری کمنیتس\nمدار و طراحی سیستم';

  @override
  String get aboutLicenseLabel => 'مجوز';

  @override
  String get aboutLicensePackageLabel => 'مجوز بسته‌های استفاده شده';

  @override
  String get aboutSourceCodeLabel => 'کد منبع';

  @override
  String get helpTitle => 'کمک';

  @override
  String get helpOnboardingLabel => 'معرفی را دوباره مشاهده کنید';

  @override
  String get helpReportErrorLabel => 'گزارش خطا';

  @override
  String get helpImproveTranslationLabel => 'کمک در ترجمه';

  @override
  String get onboardingGreetingTitle => 'سلام!';

  @override
  String get onboardingGreetingDescription => 'ما خوشحالیم که شما اینجا هستید و می‌خواهید سهم خود را برای بهبود حمل و نقل عمومی انجام دهید.';

  @override
  String get onboardingGreetingButton => 'در اینجا نحوه چگونگی کار را مشاهده کنید';

  @override
  String get onboardingSurveyingTitle => 'نگاهی بیاندازید';

  @override
  String get onboardingSurveyingDescription => 'Go to a nearby stop to survey its current state.';

  @override
  String get onboardingSurveyingButton => 'من انجامش می‌دهم';

  @override
  String get onboardingAnsweringTitle => 'حالا نوبت شماست';

  @override
  String get onboardingAnsweringDescription => 'به منظور جمع‌آوری داده‌ها، یک نشانگر در برنامه انتخاب کنید و به سوالات نمایش داده شده پاسخ دهید.';

  @override
  String get onboardingAnsweringButton => 'باشه فهمیدم';

  @override
  String get onboardingContributingTitle => 'Sharing is caring';

  @override
  String get onboardingContributingDescription => 'Upload your answers to OpenStreetMap to share them with the whole world.';

  @override
  String get onboardingContributingButton => 'Here we go';

  @override
  String get privacyPolicyTitle => 'سیاست حفظ حریم خصوصی';

  @override
  String get settingsTitle => 'تنظیمات';

  @override
  String get settingsProfessionalQuestionsLabel => 'نمایش سوالات حرفه‌ای';

  @override
  String get settingsProfessionalQuestionsDescription => 'For safety reasons only intended for professionals';

  @override
  String get settingsThemeLabel => 'Color Scheme of the App';

  @override
  String get settingsThemeDialogTitle => 'انتخاب تم';

  @override
  String get settingsThemeOptionSystem => 'تنظیمات سیستم';

  @override
  String get settingsThemeOptionLight => 'روشن';

  @override
  String get settingsThemeOptionDark => 'تیره';

  @override
  String get logoutDialogTitle => 'Log out of OSM?';

  @override
  String get logoutDialogDescription => 'If you log out, you can no longer upload changes to OpenStreetMap.';

  @override
  String get loginHint => 'Log in with your OpenStreetMap account to upload your changes.';

  @override
  String get numberInputPlaceholder => 'Enter here…';

  @override
  String get numberInputFallbackName => 'Value';

  @override
  String get numberInputValidationError => 'Invalid number';

  @override
  String numberInputValidationErrorMax(String nameString, num max, String unit) {
    return '$nameString must be less than $max$unit.';
  }

  @override
  String numberInputValidationErrorMin(String nameString, num min, String unit) {
    return '$nameString must be greater than $min$unit.';
  }

  @override
  String get stringInputPlaceholder => 'Enter here…';

  @override
  String get stringInputValidationErrorMin => 'Input too short';

  @override
  String changesetCommentMessage(String mapFeaturesString, String stopsString) {
    return 'Added details to $mapFeaturesString in stop area $stopsString.';
  }

  @override
  String get changesetCommentConjunctionString => 'و';

  @override
  String get uploadMessageSuccess => 'Changes successfully uploaded.';

  @override
  String get uploadMessageServerConnectionError => 'Error: No connection to the OSM server.';

  @override
  String get uploadMessageUnknownConnectionError => 'Unknown error during transmission.';

  @override
  String get queryMessageServerUnavailableError => 'Server unavailable or overloaded. Try again later.';

  @override
  String get queryMessageTooManyRequestsError => 'Too many requests to the server.';

  @override
  String get queryMessageConnectionTimeoutError => 'Error: Server query timed out.';

  @override
  String get queryMessageReceiveTimeoutError => 'Error: Receiving data timed out.';

  @override
  String get queryMessageUnknownServerCommunicationError => 'Unknown error during server communication.';

  @override
  String get queryMessageUnknownError => 'Unknown error.';

  @override
  String questionnaireSummaryDedicatedMessage(String userName) {
    return 'Thank you $userName for your answers.\nPlease verify them before uploading.';
  }

  @override
  String get questionnaireSummaryUndedicatedMessage => 'Thank you for your answers.\nPlease verify them before uploading.';

  @override
  String get back => 'بازگشت';

  @override
  String get next => 'بعدی';

  @override
  String get cancel => 'لغو';

  @override
  String get confirm => 'تایید';

  @override
  String get finish => 'پایان';

  @override
  String get login => 'ورود';

  @override
  String get logout => 'خروج';

  @override
  String get skip => 'رد کردن';

  @override
  String get yes => 'بله';

  @override
  String get no => 'خیر';

  @override
  String days(num day) {
    String _temp0 = intl.Intl.pluralLogic(
      day,
      locale: localeName,
      other: '$day days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String hours(num hour) {
    String _temp0 = intl.Intl.pluralLogic(
      hour,
      locale: localeName,
      other: '$hour hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String minutes(num minute) {
    String _temp0 = intl.Intl.pluralLogic(
      minute,
      locale: localeName,
      other: '$minute minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String seconds(num second) {
    String _temp0 = intl.Intl.pluralLogic(
      second,
      locale: localeName,
      other: '$second seconds',
      one: '1 second',
    );
    return '$_temp0';
  }

  @override
  String get and => 'و';

  @override
  String get more => 'بیشتر';

  @override
  String get element => 'element';

  @override
  String get durationInputDaysLabel => 'روز';

  @override
  String get durationInputHoursLabel => 'ساعت';

  @override
  String get durationInputMinutesLabel => 'دقیقه';

  @override
  String get durationInputSecondsLabel => 'ثانیه';

  @override
  String get osmCreditsText => 'Data © OpenStreetMap contributors';

  @override
  String changesetWithStopNameText(String elements, String stopArea) {
    return 'Added details to $elements in the stop area $stopArea.';
  }

  @override
  String changesetWithoutStopNameText(String elements) {
    return 'Added details to $elements in the stop area.';
  }

  @override
  String get mapFeatureBusStop => 'ایستگاه اتوبوس';

  @override
  String get mapFeatureTramStop => 'Tram stop';

  @override
  String get mapFeatureTrainPlatform => 'Train platform';

  @override
  String get mapFeaturePlatform => 'Platform';

  @override
  String get mapFeatureStopPole => 'Stop pole';

  @override
  String get mapFeatureStation => 'Station';

  @override
  String get mapFeatureTicketSalesPoint => 'Ticket sales point';

  @override
  String get mapFeatureInformationPoint => 'Information point';

  @override
  String get mapFeatureStationMap => 'Station/Stop map';

  @override
  String get mapFeatureTicketMachine => 'Ticket machine';

  @override
  String get mapFeatureParkingSpot => 'Parking spot';

  @override
  String get mapFeatureTaxiStand => 'Taxi stand';

  @override
  String get mapFeatureToilets => 'Toilets';

  @override
  String get mapFeatureLuggageLockers => 'Luggage lockers';

  @override
  String get mapFeatureLuggageTransport => 'Luggage transport';

  @override
  String get mapFeatureInformationTerminal => 'Information terminal';

  @override
  String get mapFeatureInformationCallPoint => 'Information column';

  @override
  String get mapFeatureHelpPoint => 'نقطه راهنما';

  @override
  String get mapFeatureEmergencyCallPoint => 'نقطه تماس اضطراری';

  @override
  String get mapFeatureEntrance => 'Entrance';

  @override
  String get mapFeatureFootpath => 'Footpath';

  @override
  String get mapFeatureCyclePath => 'Cycle path';

  @override
  String get mapFeatureFootAndCyclePath => 'Foot & cycle path';

  @override
  String get mapFeatureStairs => 'Stairs';

  @override
  String get mapFeatureElevator => 'Elevator';

  @override
  String get mapFeatureEscalator => 'پله برقی';

  @override
  String get mapFeatureCycleBarrier => 'Cycle barrier';

  @override
  String get mapFeatureCrossing => 'Crossing';

  @override
  String get mapFeatureTramCrossing => 'Tram crossing';

  @override
  String get mapFeatureRailroadCrossing => 'Railroad crossing';

  @override
  String get mapFeatureFootwayCrossing => 'Footway crossing';

  @override
  String get mapFeatureCyclewayCrossing => 'Cycleway crossing';

  @override
  String get mapFeatureCurb => 'Curb';

  @override
  String get mapFeaturePedestrianLights => 'Pedestrian lights';

  @override
  String mapFeatureBusPlatformNumber(String number) {
    return 'سکو: $number';
  }

  @override
  String mapFeatureTrainPlatformNumber(String number) {
    return 'سکو: $number';
  }

  @override
  String get semanticsLoginHint => 'Log in with your OpenStreetMap account to upload your changes.';

  @override
  String get semanticsFlutterMap => 'Map screen';

  @override
  String get semanticsReturnToMap => 'Close questionnaire and return to map';

  @override
  String semanticsDotsIndicator(num number) {
    return 'Page $number';
  }

  @override
  String semanticsPageIndicators(num number) {
    return 'There are $number introduction pages, select the one you would like to hear.';
  }

  @override
  String semanticsIntroductionPage(num number, num count) {
    return 'Introduction page $number of $count';
  }

  @override
  String get semanticsSlogan => 'Slogan';

  @override
  String get semanticsMFundImage => 'Funded by mFUND';

  @override
  String get semanticsFederalMinistryImage => 'Funded by Federal Ministry of Transport and Digital Infrastructure';

  @override
  String get semanticsSettingsDialogBox => 'Choose your preferred app theme';

  @override
  String get semanticsNavigationMenu => 'Navigation menu';

  @override
  String get semanticsResetRotationButton => 'Reset map rotation to north.';

  @override
  String get semanticsCurrentLocationButton => 'Set map to current location.';

  @override
  String get semanticsZoomInButton => 'Zoom in map';

  @override
  String get semanticsZoomOutButton => 'Zoom out map';

  @override
  String get semanticsQuestionSentence => 'The question is: ';

  @override
  String get semanticsUploadQuestionsButton => 'Upload answers';

  @override
  String get semanticsBackQuestionButton => 'Return to previous question.';

  @override
  String get semanticsNextQuestionButton => 'Next question';

  @override
  String get semanticsSkipQuestionButton => 'Skip question';

  @override
  String get semanticsFinishQuestionnaireButton => 'Finish questionnaire';

  @override
  String get semanticsSummary => 'Summary';

  @override
  String get semanticsCloseNavigationMenuButton => 'Close navigation menu.';

  @override
  String get semanticsCloseQuestionnaireAnnounce => 'Questionnaire is closed';

  @override
  String get semanticsOpenQuestionnaireAnnounce => 'Questionnaire is open';

  @override
  String semanticsUser(Object username) {
    return 'User $username activate to open browser profile';
  }

  @override
  String get semanticsLogout => 'Log out from your user account';

  @override
  String get semanticsClearField => 'Clear field';

  @override
  String get semanticsDurationAnswerReset => 'Reset duration';

  @override
  String get semanticsDurationAnswerStartStopwatch => 'Start stopwatch';

  @override
  String get semanticsDurationAnswerStopStopwatch => 'Stop stopwatch';

  @override
  String get semanticsReviewQuestion => 'Activate to return to question';

  @override
  String get semanticsNextStepOnboarding => 'Next page';

  @override
  String get semanticsFinishOnboarding => 'Finish introduction';

  @override
  String get semanticsCredits => 'Credits';
}
