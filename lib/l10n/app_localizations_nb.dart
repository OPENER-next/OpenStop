// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Bokmål (`nb`).
class AppLocalizationsNb extends AppLocalizations {
  AppLocalizationsNb([String locale = 'nb']) : super(locale);

  @override
  String get aboutTitle => 'Om';

  @override
  String get aboutSlogan => 'Neste stoppested: Tilgjengelighet';

  @override
  String get aboutVersionLabel => 'Versjon';

  @override
  String get aboutAuthorsLabel => 'Utviklere';

  @override
  String aboutAuthorsDescription(String appName) {
    return '$appName-bidragsytere';
  }

  @override
  String get aboutPrivacyPolicyLabel => 'Personvernspraksis';

  @override
  String get aboutIdeaLabel => 'Idé';

  @override
  String get aboutIdeaDescription => 'Chemnitz teknologiuniversitet\nFakultet for krets- og systemdesign';

  @override
  String get aboutLicenseLabel => 'Lisens';

  @override
  String get aboutLicensePackageLabel => 'Lisenser for anvendte pakker';

  @override
  String get aboutSourceCodeLabel => 'Kildekode';

  @override
  String get helpTitle => 'Hjelp';

  @override
  String get helpOnboardingLabel => 'Vis introduksjonen igjen';

  @override
  String get helpReportErrorLabel => 'Rapporter feil';

  @override
  String get helpImproveTranslationLabel => 'Improve the translation';

  @override
  String get onboardingGreetingTitle => 'Hei';

  @override
  String get onboardingGreetingDescription => 'Takk for at du gjør ditt for å forbedre offentlig transport';

  @override
  String get onboardingGreetingButton => 'Slik virker det';

  @override
  String get onboardingSurveyingTitle => 'Ta en titt';

  @override
  String get onboardingSurveyingDescription => 'Gå til et stoppested i nærheten for å sjekke nåværende tilstand.';

  @override
  String get onboardingSurveyingButton => 'På vei';

  @override
  String get onboardingAnsweringTitle => 'Nå er det din tur';

  @override
  String get onboardingAnsweringDescription => 'For å semle data kan du velge en markør i programmet og besvare tilhørende spørsmål.';

  @override
  String get onboardingAnsweringButton => 'OK, skjønner';

  @override
  String get onboardingContributingTitle => 'Del, ikke knel';

  @override
  String get onboardingContributingDescription => 'Laster opp svarene dine til OSM for å dele dem med hele verden.';

  @override
  String get onboardingContributingButton => 'Da tar vi bladet fra munnen';

  @override
  String get privacyPolicyTitle => 'Personvernspraksis';

  @override
  String get settingsTitle => 'Innstillinger';

  @override
  String get settingsProfessionalQuestionsLabel => 'Vis avanserte spørsmål';

  @override
  String get settingsProfessionalQuestionsDescription => 'Av trygghetshensyn kun tiltenkt profesjonelle';

  @override
  String get settingsThemeLabel => 'Fargedrakt for programmet';

  @override
  String get settingsThemeDialogTitle => 'Velg drakt';

  @override
  String get settingsThemeOptionSystem => 'System';

  @override
  String get settingsThemeOptionLight => 'Lys';

  @override
  String get settingsThemeOptionDark => 'Mørk';

  @override
  String get logoutDialogTitle => 'Logg ut fra OSM?';

  @override
  String get logoutDialogDescription => 'Hvis du logger ut kan du ikke laste opp endringer til OpenStreetMap.';

  @override
  String get loginHint => 'Logg inn med OpenStreetMap-konto for å laste opp endringene dine.';

  @override
  String get numberInputPlaceholder => 'Skriv inn her …';

  @override
  String get numberInputFallbackName => 'Verdi';

  @override
  String get numberInputValidationError => 'Ugyldig nummer';

  @override
  String numberInputValidationErrorMax(String nameString, num max, String unit) {
    return '$nameString må være mindre enn $max.';
  }

  @override
  String numberInputValidationErrorMin(String nameString, num min, String unit) {
    return '$nameString må være større enn $min.';
  }

  @override
  String get stringInputPlaceholder => 'Skriv inn her …';

  @override
  String get stringInputValidationErrorMin => 'Inndata for kort';

  @override
  String changesetCommentMessage(String mapFeaturesString, String stopsString) {
    return 'La til detaljer for $mapFeaturesString på stoppestedet $stopsString.';
  }

  @override
  String get changesetCommentConjunctionString => 'og';

  @override
  String get uploadMessageSuccess => 'Endringer opplastet.';

  @override
  String get uploadMessageServerConnectionError => 'Feil: Ingen tilkobling til OSM-tjeneren.';

  @override
  String get uploadMessageUnknownConnectionError => 'Ukjent feil under overføring.';

  @override
  String get queryMessageServerUnavailableError => 'Tjeneren er utilgjengelig eller overbelastet. Prøv igjen senere.';

  @override
  String get queryMessageTooManyRequestsError => 'For mange forespørsler til tjeneren.';

  @override
  String get queryMessageConnectionTimeoutError => 'Feil: Tidsavbrudd for tjenerforespørsel.';

  @override
  String get queryMessageReceiveTimeoutError => 'Feil: Tidsavbrudd for mottak av data.';

  @override
  String get queryMessageUnknownServerCommunicationError => 'Ukjent feil under tjenerkommunikasjon.';

  @override
  String get queryMessageUnknownError => 'Ukjent feil.';

  @override
  String questionnaireSummaryDedicatedMessage(String userName) {
    return 'Takk for svarene dine $userName.\nVerifiser dem før opplasting.';
  }

  @override
  String get questionnaireSummaryUndedicatedMessage => 'Takk for svarene dine.\nVerifiser dem før opplasting.';

  @override
  String get back => 'Tilbake';

  @override
  String get next => 'Neste';

  @override
  String get cancel => 'Avbryt';

  @override
  String get confirm => 'Bekreft';

  @override
  String get finish => 'Fullfør';

  @override
  String get login => 'Logg inn';

  @override
  String get logout => 'Logg ut';

  @override
  String get skip => 'Hopp over';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nei';

  @override
  String days(num day) {
    String _temp0 = intl.Intl.pluralLogic(
      day,
      locale: localeName,
      other: '$day dager',
      one: '1 dag',
    );
    return '$_temp0';
  }

  @override
  String hours(num hour) {
    String _temp0 = intl.Intl.pluralLogic(
      hour,
      locale: localeName,
      other: '$hour timer',
      one: '1 time',
    );
    return '$_temp0';
  }

  @override
  String minutes(num minute) {
    String _temp0 = intl.Intl.pluralLogic(
      minute,
      locale: localeName,
      other: '$minute minutter',
      one: '1 minutt',
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
  String get and => 'og';

  @override
  String get more => 'mer';

  @override
  String get element => 'element';

  @override
  String get durationInputDaysLabel => 'dager';

  @override
  String get durationInputHoursLabel => 'timer';

  @override
  String get durationInputMinutesLabel => 'minutter';

  @override
  String get durationInputSecondsLabel => 'sekunder';

  @override
  String get osmCreditsText => 'Data © OpenStreetMap-bidragsytere';

  @override
  String changesetWithStopNameText(String elements, String stopArea) {
    return 'La til detaljer for $elements på stoppestedet $stopArea.';
  }

  @override
  String changesetWithoutStopNameText(String elements) {
    return 'La til detaljer for $elements på stoppestedet.';
  }

  @override
  String get mapFeatureBusStop => 'Buss-stopp';

  @override
  String get mapFeatureTramStop => 'Trikkestopp';

  @override
  String get mapFeatureTrainPlatform => 'Togplattform';

  @override
  String get mapFeaturePlatform => 'Plattform';

  @override
  String get mapFeatureStopPole => 'Stoppestedsstolpe';

  @override
  String get mapFeatureStation => 'Stasjon';

  @override
  String get mapFeatureTicketSalesPoint => 'Billettsalg';

  @override
  String get mapFeatureInformationPoint => 'Informasjonssted';

  @override
  String get mapFeatureStationMap => 'Stasjons-/stoppkart';

  @override
  String get mapFeatureTicketMachine => 'Billettmaskin';

  @override
  String get mapFeatureParkingSpot => 'Parkeringssted';

  @override
  String get mapFeatureTaxiStand => 'Drosjeholdeplass';

  @override
  String get mapFeatureToilets => 'Toaletter';

  @override
  String get mapFeatureLuggageLockers => 'Bagassjeskap';

  @override
  String get mapFeatureLuggageTransport => 'Baggasjetransport';

  @override
  String get mapFeatureInformationTerminal => 'Infoterminal';

  @override
  String get mapFeatureInformationCallPoint => 'Informasjonskolonne';

  @override
  String get mapFeatureHelpPoint => 'Hjelpested';

  @override
  String get mapFeatureEmergencyCallPoint => 'Nødtelefon';

  @override
  String get mapFeatureEntrance => 'Inngang';

  @override
  String get mapFeatureFootpath => 'Gangvei';

  @override
  String get mapFeatureCyclePath => 'Cycle path';

  @override
  String get mapFeatureFootAndCyclePath => 'Foot & cycle path';

  @override
  String get mapFeatureStairs => 'Trapp';

  @override
  String get mapFeatureElevator => 'Heis';

  @override
  String get mapFeatureEscalator => 'Rulletrapp';

  @override
  String get mapFeatureCycleBarrier => 'Sykkelbarriere';

  @override
  String get mapFeatureCrossing => 'Kryssing';

  @override
  String get mapFeatureTramCrossing => 'Trikkeovergang';

  @override
  String get mapFeatureRailroadCrossing => 'Togovergang';

  @override
  String get mapFeatureFootwayCrossing => 'Fotgjengerkryssing';

  @override
  String get mapFeatureCyclewayCrossing => 'Sykkelkryssing';

  @override
  String get mapFeatureCurb => 'Kantstein';

  @override
  String get mapFeaturePedestrianLights => 'Fotgjenger-trafikklys';

  @override
  String mapFeatureBusPlatformNumber(String number) {
    return 'Plattform: $number';
  }

  @override
  String mapFeatureTrainPlatformNumber(String number) {
    return 'Plattform: $number';
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
