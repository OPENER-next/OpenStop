// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get aboutTitle => 'O aplikaci';

  @override
  String get aboutSlogan => 'Další zastávka: Přístupnost';

  @override
  String get aboutVersionLabel => 'Verze';

  @override
  String get aboutAuthorsLabel => 'Autoři';

  @override
  String aboutAuthorsDescription(String appName) {
    return '$appName přispěvatelé';
  }

  @override
  String get aboutPrivacyPolicyLabel => 'Zásady ochrany osobních údajů';

  @override
  String get aboutIdeaLabel => 'Nápady';

  @override
  String get aboutIdeaDescription => 'Technická univerzita Chemnitz\nProfesorský okruh a systémový design';

  @override
  String get aboutLicenseLabel => 'Licence';

  @override
  String get aboutLicensePackageLabel => 'Licence použitých balíčků';

  @override
  String get aboutSourceCodeLabel => 'Zdrojový kód';

  @override
  String get helpTitle => 'Pomoc';

  @override
  String get helpOnboardingLabel => 'Podívat se znovu na úvod';

  @override
  String get helpReportErrorLabel => 'Nahlásit chybu';

  @override
  String get helpImproveTranslationLabel => 'Vylepšení překladu';

  @override
  String get onboardingGreetingTitle => 'Ahoj!';

  @override
  String get onboardingGreetingDescription => 'Jsme rádi, že jste tady a chcete přispět ke zlepšení veřejné dopravy.';

  @override
  String get onboardingGreetingButton => 'Tady je návod, jak to funguje';

  @override
  String get onboardingSurveyingTitle => 'Podívejte se';

  @override
  String get onboardingSurveyingDescription => 'Jděte na blízkou zastávku a prohlédněte si její aktuální stav.';

  @override
  String get onboardingSurveyingButton => 'Udělám to';

  @override
  String get onboardingAnsweringTitle => 'Nyní jste na řadě vy';

  @override
  String get onboardingAnsweringDescription => 'Chcete-li shromáždit údaje, vyberte v aplikaci značku a odpovězte na zobrazené otázky.';

  @override
  String get onboardingAnsweringButton => 'Dobře, rozumím';

  @override
  String get onboardingContributingTitle => 'Sdílet znamená pečovat';

  @override
  String get onboardingContributingDescription => 'Nahrajte své odpovědi na OpenStreetMap a podělte se o ně s celým světem.';

  @override
  String get onboardingContributingButton => 'Jdeme na to';

  @override
  String get privacyPolicyTitle => 'Zásady ochrany osobních údajů';

  @override
  String get settingsTitle => 'Nastavení';

  @override
  String get settingsProfessionalQuestionsLabel => 'Zobrazit odborné otázky';

  @override
  String get settingsProfessionalQuestionsDescription => 'Z bezpečnostních důvodů určeno pouze pro profesionály';

  @override
  String get settingsThemeLabel => 'Barevné schéma aplikace';

  @override
  String get settingsThemeDialogTitle => 'Zvolte téma';

  @override
  String get settingsThemeOptionSystem => 'Nastavení systému';

  @override
  String get settingsThemeOptionLight => 'Světlé';

  @override
  String get settingsThemeOptionDark => 'Tmavé';

  @override
  String get logoutDialogTitle => 'Odhlášení z OSM?';

  @override
  String get logoutDialogDescription => 'Pokud se odhlásíte, nemůžete již do OpenStreetMap nahrávat změny.';

  @override
  String get loginHint => 'Přihlaste se pomocí svého účtu OpenStreetMap a nahrajte své změny.';

  @override
  String get numberInputPlaceholder => 'Zadejte zde…';

  @override
  String get numberInputFallbackName => 'Hodnota';

  @override
  String get numberInputValidationError => 'Neplatné číslo';

  @override
  String numberInputValidationErrorMax(String nameString, num max, String unit) {
    return '$nameString musí být menší než $max$unit.';
  }

  @override
  String numberInputValidationErrorMin(String nameString, num min, String unit) {
    return '$nameString musí být větší než $min$unit.';
  }

  @override
  String get stringInputPlaceholder => 'Vložit zde…';

  @override
  String get stringInputValidationErrorMin => 'Vstup je příliš krátký';

  @override
  String changesetCommentMessage(String mapFeaturesString, String stopsString) {
    return 'Přidány podrobnosti do $mapFeaturesString v oblasti zastávky $stopsString.';
  }

  @override
  String get changesetCommentConjunctionString => 'a';

  @override
  String get uploadMessageSuccess => 'Změny byly úspěšně nahrány.';

  @override
  String get uploadMessageServerConnectionError => 'Chyba: Žádné připojení k serveru OSM.';

  @override
  String get uploadMessageUnknownConnectionError => 'Neznámá chyba během přenosu.';

  @override
  String get queryMessageServerUnavailableError => 'Server je nedostupný nebo přetížený. Zkuste to později znovu.';

  @override
  String get queryMessageTooManyRequestsError => 'Příliš mnoho požadavků na server.';

  @override
  String get queryMessageConnectionTimeoutError => 'Chyba: Vypršel časový limit dotazu serveru.';

  @override
  String get queryMessageReceiveTimeoutError => 'Chyba: Časový limit příjmu dat vypršel.';

  @override
  String get queryMessageUnknownServerCommunicationError => 'Neznámá chyba během komunikace se serverem.';

  @override
  String get queryMessageUnknownError => 'Neznámá chyba.';

  @override
  String questionnaireSummaryDedicatedMessage(String userName) {
    return 'Děkujeme $userName za vaše odpovědi.\nPřed nahráním je prosím ověřte.';
  }

  @override
  String get questionnaireSummaryUndedicatedMessage => 'Děkuji za vaše odpovědi.\nPřed nahráním je prosím ověřte.';

  @override
  String get back => 'Zpět';

  @override
  String get next => 'Další';

  @override
  String get cancel => 'Zrušit';

  @override
  String get confirm => 'Potvrdit';

  @override
  String get finish => 'Dokončit';

  @override
  String get login => 'Přihlásit se';

  @override
  String get logout => 'Odhlásit se';

  @override
  String get skip => 'Přeskočit';

  @override
  String get yes => 'Ano';

  @override
  String get no => 'Ne';

  @override
  String days(num day) {
    String _temp0 = intl.Intl.pluralLogic(
      day,
      locale: localeName,
      other: '$day dny',
      one: '1 den',
    );
    return '$_temp0';
  }

  @override
  String hours(num hour) {
    String _temp0 = intl.Intl.pluralLogic(
      hour,
      locale: localeName,
      other: '$hour hodiny',
      one: '1 hodina',
    );
    return '$_temp0';
  }

  @override
  String minutes(num minute) {
    String _temp0 = intl.Intl.pluralLogic(
      minute,
      locale: localeName,
      other: '$minute minuty',
      one: '1 minuta',
    );
    return '$_temp0';
  }

  @override
  String seconds(num second) {
    String _temp0 = intl.Intl.pluralLogic(
      second,
      locale: localeName,
      other: '$second sekundy',
      one: '1 sekunda',
    );
    return '$_temp0';
  }

  @override
  String get and => 'a';

  @override
  String get more => 'více';

  @override
  String get element => 'element';

  @override
  String get durationInputDaysLabel => 'dny';

  @override
  String get durationInputHoursLabel => 'hodiny';

  @override
  String get durationInputMinutesLabel => 'minuty';

  @override
  String get durationInputSecondsLabel => 'sekundy';

  @override
  String get osmCreditsText => 'Data © přispěvatelé OpenStreetMap';

  @override
  String changesetWithStopNameText(String elements, String stopArea) {
    return 'Přidány podrobnosti k $elements v oblasti zastavení $stopArea.';
  }

  @override
  String changesetWithoutStopNameText(String elements) {
    return 'Přidány podrobnosti k $elements v oblasti zastávky.';
  }

  @override
  String get mapFeatureBusStop => 'Autobusová zastávka';

  @override
  String get mapFeatureTramStop => 'Tramvajová zastávka';

  @override
  String get mapFeatureTrainPlatform => 'Vlakové nástupiště';

  @override
  String get mapFeaturePlatform => 'Nástupiště';

  @override
  String get mapFeatureStopPole => 'Zastávka sloupek';

  @override
  String get mapFeatureStation => 'Stanice';

  @override
  String get mapFeatureTicketSalesPoint => 'Prodej lístků';

  @override
  String get mapFeatureInformationPoint => 'Informační centrum';

  @override
  String get mapFeatureStationMap => 'Mapa stanic a zastávek';

  @override
  String get mapFeatureTicketMachine => 'Automat na jízdenky';

  @override
  String get mapFeatureParkingSpot => 'Parkovací místo';

  @override
  String get mapFeatureTaxiStand => 'Stanoviště taxi';

  @override
  String get mapFeatureToilets => 'Toalety';

  @override
  String get mapFeatureLuggageLockers => 'Skříňky na zavazadla';

  @override
  String get mapFeatureLuggageTransport => 'Přeprava zavazadel';

  @override
  String get mapFeatureInformationTerminal => 'Informační terminál';

  @override
  String get mapFeatureInformationCallPoint => 'Informační sloupek';

  @override
  String get mapFeatureHelpPoint => 'Bod pomoci';

  @override
  String get mapFeatureEmergencyCallPoint => 'Místo tísňového volání';

  @override
  String get mapFeatureEntrance => 'Vstup';

  @override
  String get mapFeatureFootpath => 'Chodník pro pěší';

  @override
  String get mapFeatureCyclePath => 'Cycle path';

  @override
  String get mapFeatureFootAndCyclePath => 'Foot & cycle path';

  @override
  String get mapFeatureStairs => 'Schody';

  @override
  String get mapFeatureElevator => 'Výtah';

  @override
  String get mapFeatureEscalator => 'Eskalátor';

  @override
  String get mapFeatureCycleBarrier => 'Bariéra pro cyklisty';

  @override
  String get mapFeatureCrossing => 'Přechod';

  @override
  String get mapFeatureTramCrossing => 'Tramvajový přejezd';

  @override
  String get mapFeatureRailroadCrossing => 'Železniční přejezd';

  @override
  String get mapFeatureFootwayCrossing => 'Přechod pro chodce';

  @override
  String get mapFeatureCyclewayCrossing => 'Přechod přes cyklostezku';

  @override
  String get mapFeatureCurb => 'Obrubník';

  @override
  String get mapFeaturePedestrianLights => 'Semafory pro chodce';

  @override
  String mapFeatureBusPlatformNumber(String number) {
    return 'Nástupiště: $number';
  }

  @override
  String mapFeatureTrainPlatformNumber(String number) {
    return 'Nástupiště: $number';
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
