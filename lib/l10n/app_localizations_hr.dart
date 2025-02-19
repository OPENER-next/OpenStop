// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Croatian (`hr`).
class AppLocalizationsHr extends AppLocalizations {
  AppLocalizationsHr([String locale = 'hr']) : super(locale);

  @override
  String get aboutTitle => 'O aplikaciji';

  @override
  String get aboutSlogan => 'Sljedeća postaja: Pristupačnost';

  @override
  String get aboutVersionLabel => 'Verzija';

  @override
  String get aboutAuthorsLabel => 'Autori';

  @override
  String aboutAuthorsDescription(String appName) {
    return '$appName suradnici';
  }

  @override
  String get aboutPrivacyPolicyLabel => 'Politika privatnosti';

  @override
  String get aboutIdeaLabel => 'Ideja';

  @override
  String get aboutIdeaDescription => 'Chemnitz University of Technology\nProfessorship Circuit and System Design';

  @override
  String get aboutLicenseLabel => 'Licenca';

  @override
  String get aboutLicensePackageLabel => 'Licence korištenih paketa';

  @override
  String get aboutSourceCodeLabel => 'Izvorni kod';

  @override
  String get helpTitle => 'Pomoć';

  @override
  String get helpOnboardingLabel => 'Ponovno pogledaj uvod';

  @override
  String get helpReportErrorLabel => 'Prijavi grešku';

  @override
  String get helpImproveTranslationLabel => 'Improve the translation';

  @override
  String get onboardingGreetingTitle => 'Hej!';

  @override
  String get onboardingGreetingDescription => 'Drago nam je što si ovdje i želiš dati svoj doprinos poboljšanju javnog prijevoza.';

  @override
  String get onboardingGreetingButton => 'Evo kako to radi';

  @override
  String get onboardingSurveyingTitle => 'Pogledaj';

  @override
  String get onboardingSurveyingDescription => 'Otiđi do obližnje stanice da provjeriš njezino trenutno stanje.';

  @override
  String get onboardingSurveyingButton => 'Učinit ću to';

  @override
  String get onboardingAnsweringTitle => 'Sad je red na tebi';

  @override
  String get onboardingAnsweringDescription => 'Za prikupljanje podataka klikni na marker u aplikaciji i odgovori na prikazana pitanja.';

  @override
  String get onboardingAnsweringButton => 'U redu, razumijem';

  @override
  String get onboardingContributingTitle => 'Dijeljenje znači brižnost';

  @override
  String get onboardingContributingDescription => 'Pošalji svoje odgovore na OpenStreetMap da ih podijeliš s cijelim svijetom.';

  @override
  String get onboardingContributingButton => 'Idemo';

  @override
  String get privacyPolicyTitle => 'Politika privatnosti';

  @override
  String get settingsTitle => 'Postavke';

  @override
  String get settingsProfessionalQuestionsLabel => 'Prikaži stručna pitanja';

  @override
  String get settingsProfessionalQuestionsDescription => 'Iz sigurnosnih razloga namijenjeno samo profesionalcima';

  @override
  String get settingsThemeLabel => 'Shema boja aplikacije';

  @override
  String get settingsThemeDialogTitle => 'Odaberi temu';

  @override
  String get settingsThemeOptionSystem => 'Sistemski zadano';

  @override
  String get settingsThemeOptionLight => 'Svjetla';

  @override
  String get settingsThemeOptionDark => 'Tamna';

  @override
  String get logoutDialogTitle => 'Odjavi se s OSM-a?';

  @override
  String get logoutDialogDescription => 'Ako se odjaviš, više nećeš moći slati izmjene na OpenStreetMap.';

  @override
  String get loginHint => 'Prijavi se sa svojim OpenStreetMap računom kako bi poslao svoje izmjene.';

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
  String get changesetCommentConjunctionString => 'and';

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
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get finish => 'Finish';

  @override
  String get login => 'Log in';

  @override
  String get logout => 'Log out';

  @override
  String get skip => 'Skip';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

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
  String get and => 'and';

  @override
  String get more => 'more';

  @override
  String get element => 'element';

  @override
  String get durationInputDaysLabel => 'days';

  @override
  String get durationInputHoursLabel => 'hours';

  @override
  String get durationInputMinutesLabel => 'minutes';

  @override
  String get durationInputSecondsLabel => 'seconds';

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
  String get mapFeatureBusStop => 'Bus stop';

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
  String get mapFeatureHelpPoint => 'Help point';

  @override
  String get mapFeatureEmergencyCallPoint => 'Emergency call point';

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
  String get mapFeatureEscalator => 'Escalator';

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
    return 'Platform: $number';
  }

  @override
  String mapFeatureTrainPlatformNumber(String number) {
    return 'Platform: $number';
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
