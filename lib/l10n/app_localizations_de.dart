// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get aboutTitle => 'Über';

  @override
  String get aboutSlogan => 'Nächster Halt: Barrierefreiheit';

  @override
  String get aboutVersionLabel => 'Version';

  @override
  String get aboutAuthorsLabel => 'Autoren';

  @override
  String aboutAuthorsDescription(String appName) {
    return '$appName-Mitwirkende';
  }

  @override
  String get aboutPrivacyPolicyLabel => 'Datenschutzerklärung';

  @override
  String get aboutIdeaLabel => 'Idee';

  @override
  String get aboutIdeaDescription => 'Technische Universität Chemnitz\nProfessur Schaltkreis- und Systementwurf';

  @override
  String get aboutLicenseLabel => 'Lizenz';

  @override
  String get aboutLicensePackageLabel => 'Lizenzen verwendeter Pakete';

  @override
  String get aboutSourceCodeLabel => 'Quellcode';

  @override
  String get helpTitle => 'Hilfe';

  @override
  String get helpOnboardingLabel => 'Einführung erneut anschauen';

  @override
  String get helpReportErrorLabel => 'Fehler melden';

  @override
  String get helpImproveTranslationLabel => 'Übersetzung verbessern';

  @override
  String get onboardingGreetingTitle => 'Hey!';

  @override
  String get onboardingGreetingDescription => 'Wir freuen uns, dass du hier bist und deinen Teil zu einem besseren Nahverkehr beitragen willst.';

  @override
  String get onboardingGreetingButton => 'So funktioniert\'s';

  @override
  String get onboardingSurveyingTitle => 'Schau\'s dir an';

  @override
  String get onboardingSurveyingDescription => 'Begib dich zu einer Haltestelle in deiner Umgebung, um ihren aktuellen Zustand zu erfassen.';

  @override
  String get onboardingSurveyingButton => 'Mach\' ich';

  @override
  String get onboardingAnsweringTitle => 'Jetzt bist du gefragt';

  @override
  String get onboardingAnsweringDescription => 'Wähle zur Erfassung einen Marker in der App aus und beantworte die angezeigten Fragen.';

  @override
  String get onboardingAnsweringButton => 'Okay, verstanden';

  @override
  String get onboardingContributingTitle => 'Sharing is caring';

  @override
  String get onboardingContributingDescription => 'Lade deine Antworten auf OpenStreetMap hoch und stelle sie so der ganzen Welt zur Verfügung.';

  @override
  String get onboardingContributingButton => 'Los geht\'s';

  @override
  String get privacyPolicyTitle => 'Datenschutzerklärung';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsProfessionalQuestionsLabel => 'Profi-Fragen anzeigen';

  @override
  String get settingsProfessionalQuestionsDescription => 'Aus Sicherheitsgründen nur für Fachpersonal bestimmt';

  @override
  String get settingsThemeLabel => 'Farbliche Darstellung der App';

  @override
  String get settingsThemeDialogTitle => 'Design auswählen';

  @override
  String get settingsThemeOptionSystem => 'Systemeinstellung';

  @override
  String get settingsThemeOptionLight => 'Hell';

  @override
  String get settingsThemeOptionDark => 'Dunkel';

  @override
  String get logoutDialogTitle => 'Von OSM abmelden?';

  @override
  String get logoutDialogDescription => 'Wenn du dich abmeldest, kannst du keine Änderungen mehr zu OpenStreetMap hochladen.';

  @override
  String get loginHint => 'Melde dich mit deinem OpenStreetMap-Konto an, um deine Änderungen hochzuladen.';

  @override
  String get numberInputPlaceholder => 'Hier eintragen…';

  @override
  String get numberInputFallbackName => 'Wert';

  @override
  String get numberInputValidationError => 'Ungültige Zahl';

  @override
  String numberInputValidationErrorMax(String nameString, num max, String unit) {
    return '$nameString muss kleiner sein als $max$unit.';
  }

  @override
  String numberInputValidationErrorMin(String nameString, num min, String unit) {
    return '$nameString muss größer sein als $min$unit.';
  }

  @override
  String get stringInputPlaceholder => 'Hier eintragen…';

  @override
  String get stringInputValidationErrorMin => 'Eingabe zu kurz';

  @override
  String changesetCommentMessage(String mapFeaturesString, String stopsString) {
    return 'Details zu $mapFeaturesString im Haltestellenbereich $stopsString hinzugefügt.';
  }

  @override
  String get changesetCommentConjunctionString => 'und';

  @override
  String get uploadMessageSuccess => 'Änderungen erfolgreich übertragen.';

  @override
  String get uploadMessageServerConnectionError => 'Fehler: Keine Verbindung zum OSM-Server.';

  @override
  String get uploadMessageUnknownConnectionError => 'Unbekannter Fehler bei der Übertragung.';

  @override
  String get queryMessageServerUnavailableError => 'Der Server ist nicht verfügbar oder überlastet. Versuche es später noch einmal.';

  @override
  String get queryMessageTooManyRequestsError => 'Zu viele Serveranfragen.';

  @override
  String get queryMessageConnectionTimeoutError => 'Fehler: Zeitüberschreitung bei der Server-Abfrage.';

  @override
  String get queryMessageReceiveTimeoutError => 'Fehler: Zeitüberschreitung beim Datenempfang.';

  @override
  String get queryMessageUnknownServerCommunicationError => 'Unbekannter Fehler bei der Server-Kommunikation.';

  @override
  String get queryMessageUnknownError => 'Unbekannter Fehler.';

  @override
  String questionnaireSummaryDedicatedMessage(String userName) {
    return 'Danke $userName für deine Antworten.\nBitte prüfe sie vor dem Hochladen nochmal.';
  }

  @override
  String get questionnaireSummaryUndedicatedMessage => 'Danke für deine Antworten.\nBitte prüfe sie vor dem Hochladen nochmal.';

  @override
  String get back => 'Zurück';

  @override
  String get next => 'Weiter';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get finish => 'Abschließen';

  @override
  String get login => 'Anmelden';

  @override
  String get logout => 'Abmelden';

  @override
  String get skip => 'Überspringen';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String days(num day) {
    String _temp0 = intl.Intl.pluralLogic(
      day,
      locale: localeName,
      other: '$day Tage',
      one: '1 Tag',
    );
    return '$_temp0';
  }

  @override
  String hours(num hour) {
    String _temp0 = intl.Intl.pluralLogic(
      hour,
      locale: localeName,
      other: '$hour Stunden',
      one: '1 Stunde',
    );
    return '$_temp0';
  }

  @override
  String minutes(num minute) {
    String _temp0 = intl.Intl.pluralLogic(
      minute,
      locale: localeName,
      other: '$minute Minuten',
      one: '1 Minute',
    );
    return '$_temp0';
  }

  @override
  String seconds(num second) {
    String _temp0 = intl.Intl.pluralLogic(
      second,
      locale: localeName,
      other: '$second Sekunden',
      one: '1 Sekunde',
    );
    return '$_temp0';
  }

  @override
  String get and => 'und';

  @override
  String get more => 'mehr';

  @override
  String get element => 'Element';

  @override
  String get durationInputDaysLabel => 'Tage';

  @override
  String get durationInputHoursLabel => 'Stunden';

  @override
  String get durationInputMinutesLabel => 'Minuten';

  @override
  String get durationInputSecondsLabel => 'Sekunden';

  @override
  String get osmCreditsText => 'Data © OpenStreetMap-Mitwirkende';

  @override
  String changesetWithStopNameText(String elements, String stopArea) {
    return 'Details zu $elements im Haltestellenbereich $stopArea hinzugefügt.';
  }

  @override
  String changesetWithoutStopNameText(String elements) {
    return 'Details zu $elements im Haltestellenbereich hinzugefügt.';
  }

  @override
  String get mapFeatureBusStop => 'Bus-Haltestelle';

  @override
  String get mapFeatureTramStop => 'Tram-Haltestelle';

  @override
  String get mapFeatureTrainPlatform => 'Bahnsteig';

  @override
  String get mapFeaturePlatform => 'Plattform';

  @override
  String get mapFeatureStopPole => 'Haltestellenmast';

  @override
  String get mapFeatureStation => 'Station';

  @override
  String get mapFeatureTicketSalesPoint => 'Fahrtkartenverkaufsstelle';

  @override
  String get mapFeatureInformationPoint => 'Informationsstelle';

  @override
  String get mapFeatureStationMap => 'Stations-/Haltestellenplan';

  @override
  String get mapFeatureTicketMachine => 'Fahrkartenautomat';

  @override
  String get mapFeatureParkingSpot => 'Parkplatz';

  @override
  String get mapFeatureTaxiStand => 'Taxi-Stand';

  @override
  String get mapFeatureToilets => 'Toiletten';

  @override
  String get mapFeatureLuggageLockers => 'Gepäckschließfächer';

  @override
  String get mapFeatureLuggageTransport => 'Gepäcktransport';

  @override
  String get mapFeatureInformationTerminal => 'Info-Terminal';

  @override
  String get mapFeatureInformationCallPoint => 'Informationssäule';

  @override
  String get mapFeatureHelpPoint => 'Kombinierte Informations- und Notrufsäule';

  @override
  String get mapFeatureEmergencyCallPoint => 'Notrufsäule';

  @override
  String get mapFeatureEntrance => 'Durchgang';

  @override
  String get mapFeatureFootpath => 'Fußweg';

  @override
  String get mapFeatureCyclePath => 'Radweg';

  @override
  String get mapFeatureFootAndCyclePath => 'Fuß- und Radweg';

  @override
  String get mapFeatureStairs => 'Treppe';

  @override
  String get mapFeatureElevator => 'Fahrstuhl';

  @override
  String get mapFeatureEscalator => 'Rolltreppe';

  @override
  String get mapFeatureCycleBarrier => 'Umlaufsperre';

  @override
  String get mapFeatureCrossing => 'Überweg';

  @override
  String get mapFeatureTramCrossing => 'Straßenbahnübergang';

  @override
  String get mapFeatureRailroadCrossing => 'Bahnübergang';

  @override
  String get mapFeatureFootwayCrossing => 'Fußgängerüberweg';

  @override
  String get mapFeatureCyclewayCrossing => 'Radüberweg';

  @override
  String get mapFeatureCurb => 'Bordstein';

  @override
  String get mapFeaturePedestrianLights => 'Fußgängerampel';

  @override
  String mapFeatureBusPlatformNumber(String number) {
    return 'Steig: $number';
  }

  @override
  String mapFeatureTrainPlatformNumber(String number) {
    return 'Gleis: $number';
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
