// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get aboutTitle => 'Om';

  @override
  String get aboutSlogan => 'Nästa station: Tillgänglighet';

  @override
  String get aboutVersionLabel => 'Version';

  @override
  String get aboutAuthorsLabel => 'Upphovsmän';

  @override
  String aboutAuthorsDescription(String appName) {
    return '${appName}s bidragsgivare';
  }

  @override
  String get aboutPrivacyPolicyLabel => 'Integritetspolicy';

  @override
  String get aboutIdeaLabel => 'Idé';

  @override
  String get aboutIdeaDescription => 'Chemnitz Tekniska Högskola\nProffesur i kretskorts- och systemdesign';

  @override
  String get aboutLicenseLabel => 'Licens';

  @override
  String get aboutLicensePackageLabel => 'Licenser för använda paket';

  @override
  String get aboutSourceCodeLabel => 'Källkod';

  @override
  String get helpTitle => 'Hjälp';

  @override
  String get helpOnboardingLabel => 'Se introduktionen igen';

  @override
  String get helpReportErrorLabel => 'Rapportera ett fel';

  @override
  String get helpImproveTranslationLabel => 'Förbättra översättningen';

  @override
  String get onboardingGreetingTitle => 'Hej!';

  @override
  String get onboardingGreetingDescription => 'Vi är glada att du är här och vill bidra till att förbättra kollektivtrafiken.';

  @override
  String get onboardingGreetingButton => 'Så här fungerar det';

  @override
  String get onboardingSurveyingTitle => 'Ta en titt';

  @override
  String get onboardingSurveyingDescription => 'Ta dig till en hållplats i närheten för att undersöka den nuvarande situationen.';

  @override
  String get onboardingSurveyingButton => 'Ska bli';

  @override
  String get onboardingAnsweringTitle => 'Nu är det din tur';

  @override
  String get onboardingAnsweringDescription => 'Välj en markör i appen och svara på frågorna för att samla in data.';

  @override
  String get onboardingAnsweringButton => 'Uppfattat';

  @override
  String get onboardingContributingTitle => 'Delad lycka är dubbel lycka';

  @override
  String get onboardingContributingDescription => 'Ladda upp dina svar till OpenStreetMap för att dela dem med hela världen.';

  @override
  String get onboardingContributingButton => 'Nu kör vi';

  @override
  String get privacyPolicyTitle => 'Integritetspolicy';

  @override
  String get settingsTitle => 'Inställningar';

  @override
  String get settingsProfessionalQuestionsLabel => 'Visa fackmässiga frågor';

  @override
  String get settingsProfessionalQuestionsDescription => 'Av säkerhetsskäl endast avsedda för yrkesmän';

  @override
  String get settingsThemeLabel => 'Appens färgsättning';

  @override
  String get settingsThemeDialogTitle => 'Välj tema';

  @override
  String get settingsThemeOptionSystem => 'Systeminställning';

  @override
  String get settingsThemeOptionLight => 'Ljust';

  @override
  String get settingsThemeOptionDark => 'Mörkt';

  @override
  String get logoutDialogTitle => 'Logga ut från OSM?';

  @override
  String get logoutDialogDescription => 'Om du loggar ut kan du inte längre ladda upp ändringar till OpenStreetMap.';

  @override
  String get loginHint => 'Logga in med ditt OpenStreetMap-konto för att ladda upp dina ändringar.';

  @override
  String get numberInputPlaceholder => 'Skriv här …';

  @override
  String get numberInputFallbackName => 'Värde';

  @override
  String get numberInputValidationError => 'Ogiltigt nummer';

  @override
  String numberInputValidationErrorMax(String nameString, num max, String unit) {
    return '$nameString måste vara mindre än $max $unit.';
  }

  @override
  String numberInputValidationErrorMin(String nameString, num min, String unit) {
    return '$nameString måste vara större än $min $unit.';
  }

  @override
  String get stringInputPlaceholder => 'Skriv här …';

  @override
  String get stringInputValidationErrorMin => 'För kort inmatning';

  @override
  String changesetCommentMessage(String mapFeaturesString, String stopsString) {
    return 'Lade till detaljer till $mapFeaturesString på hållplatsen $stopsString.';
  }

  @override
  String get changesetCommentConjunctionString => 'och';

  @override
  String get uploadMessageSuccess => 'Ändringarna har laddats upp.';

  @override
  String get uploadMessageServerConnectionError => 'Felmeddelande: Ingen anslutning till OSM-servern.';

  @override
  String get uploadMessageUnknownConnectionError => 'Okänt fel under överföringen.';

  @override
  String get queryMessageServerUnavailableError => 'Servern är otillgänglig eller överbelastad. Försök igen senare.';

  @override
  String get queryMessageTooManyRequestsError => 'För många förfrågningar till servern.';

  @override
  String get queryMessageConnectionTimeoutError => 'Felmeddelande: Tidsgränsen för begäran passerades.';

  @override
  String get queryMessageReceiveTimeoutError => 'Felmeddelande: Tidsgränsen för mottagande av data passerades.';

  @override
  String get queryMessageUnknownServerCommunicationError => 'Okänt fel vid serverkommunikation.';

  @override
  String get queryMessageUnknownError => 'Okänt fel.';

  @override
  String questionnaireSummaryDedicatedMessage(String userName) {
    return 'Tack för dina svar, $userName.\nDubbelkolla dem innan du laddar upp dem.';
  }

  @override
  String get questionnaireSummaryUndedicatedMessage => 'Tack för dina svar.\nDubbelkolla dem innan du laddar upp dem.';

  @override
  String get back => 'Tillbaka';

  @override
  String get next => 'Nästa';

  @override
  String get cancel => 'Avbryt';

  @override
  String get confirm => 'Bekräfta';

  @override
  String get finish => 'Avsluta';

  @override
  String get login => 'Logga in';

  @override
  String get logout => 'Logga ut';

  @override
  String get skip => 'Hoppa över';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nej';

  @override
  String days(num day) {
    String _temp0 = intl.Intl.pluralLogic(
      day,
      locale: localeName,
      other: '$day dagar',
      one: '1 dag',
    );
    return '$_temp0';
  }

  @override
  String hours(num hour) {
    String _temp0 = intl.Intl.pluralLogic(
      hour,
      locale: localeName,
      other: '$hour timmar',
      one: '1 timme',
    );
    return '$_temp0';
  }

  @override
  String minutes(num minute) {
    String _temp0 = intl.Intl.pluralLogic(
      minute,
      locale: localeName,
      other: '$minute minuter',
      one: '1 minut',
    );
    return '$_temp0';
  }

  @override
  String seconds(num second) {
    String _temp0 = intl.Intl.pluralLogic(
      second,
      locale: localeName,
      other: '$second sekunder',
      one: '1 sekund',
    );
    return '$_temp0';
  }

  @override
  String get and => 'och';

  @override
  String get more => 'mer';

  @override
  String get element => 'element';

  @override
  String get durationInputDaysLabel => 'dagar';

  @override
  String get durationInputHoursLabel => 'timmar';

  @override
  String get durationInputMinutesLabel => 'minuter';

  @override
  String get durationInputSecondsLabel => 'sekunder';

  @override
  String get osmCreditsText => 'Datan © OpenStreetMaps bidragsgivare';

  @override
  String changesetWithStopNameText(String elements, String stopArea) {
    return 'Lade till detaljer till $elements på hållplatsen $stopArea.';
  }

  @override
  String changesetWithoutStopNameText(String elements) {
    return 'Lade till detaljer till $elements på hållplatsen.';
  }

  @override
  String get mapFeatureBusStop => 'Busshållplats';

  @override
  String get mapFeatureTramStop => 'Spårvagnshållplats';

  @override
  String get mapFeatureTrainPlatform => 'Tågplattform';

  @override
  String get mapFeaturePlatform => 'Plattform';

  @override
  String get mapFeatureStopPole => 'Hållplatsstolpe';

  @override
  String get mapFeatureStation => 'Station';

  @override
  String get mapFeatureTicketSalesPoint => 'Biljettförsäljningsställe';

  @override
  String get mapFeatureInformationPoint => 'Informationspunkt';

  @override
  String get mapFeatureStationMap => 'Stations-/hållplatskarta';

  @override
  String get mapFeatureTicketMachine => 'Biljettautomat';

  @override
  String get mapFeatureParkingSpot => 'Parkeringsruta';

  @override
  String get mapFeatureTaxiStand => 'Taxistation';

  @override
  String get mapFeatureToilets => 'Toaletter';

  @override
  String get mapFeatureLuggageLockers => 'Förvaringsboxar';

  @override
  String get mapFeatureLuggageTransport => 'Transporttjänster för bagage';

  @override
  String get mapFeatureInformationTerminal => 'Informationsterminal';

  @override
  String get mapFeatureInformationCallPoint => 'Informationspelare';

  @override
  String get mapFeatureHelpPoint => 'Nödtelefon';

  @override
  String get mapFeatureEmergencyCallPoint => 'Nödtelefon';

  @override
  String get mapFeatureEntrance => 'Entré';

  @override
  String get mapFeatureFootpath => 'Gångväg';

  @override
  String get mapFeatureCyclePath => 'Cycle path';

  @override
  String get mapFeatureFootAndCyclePath => 'Foot & cycle path';

  @override
  String get mapFeatureStairs => 'Trappor';

  @override
  String get mapFeatureElevator => 'Hiss';

  @override
  String get mapFeatureEscalator => 'Rulltrappa';

  @override
  String get mapFeatureCycleBarrier => 'Cykelfålla';

  @override
  String get mapFeatureCrossing => 'Korsning med bilväg';

  @override
  String get mapFeatureTramCrossing => 'Spårvagnsövergång';

  @override
  String get mapFeatureRailroadCrossing => 'Järnvägskorsning';

  @override
  String get mapFeatureFootwayCrossing => 'Övergångsställe';

  @override
  String get mapFeatureCyclewayCrossing => 'Cykelöverfart eller cykelpassage';

  @override
  String get mapFeatureCurb => 'Trottoarkant';

  @override
  String get mapFeaturePedestrianLights => 'Trafikljus för fotgängare';

  @override
  String mapFeatureBusPlatformNumber(String number) {
    return 'Hållplatsläge: $number';
  }

  @override
  String mapFeatureTrainPlatformNumber(String number) {
    return 'Spår: $number';
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
