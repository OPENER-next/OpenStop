// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get aboutTitle => 'Informazioni';

  @override
  String get aboutSlogan => 'Prossimo stop: Accessibilità';

  @override
  String get aboutVersionLabel => 'Versione';

  @override
  String get aboutAuthorsLabel => 'Autori';

  @override
  String aboutAuthorsDescription(String appName) {
    return 'Collaboratori di $appName';
  }

  @override
  String get aboutPrivacyPolicyLabel => 'Informativa sulla privacy';

  @override
  String get aboutIdeaLabel => 'Idea';

  @override
  String get aboutIdeaDescription => 'Chemnitz University of Technology\nProfessorship Circuit and System Design';

  @override
  String get aboutLicenseLabel => 'Licenza';

  @override
  String get aboutLicensePackageLabel => 'Licenze dei pacchetti usati';

  @override
  String get aboutSourceCodeLabel => 'Codice sorgente';

  @override
  String get helpTitle => 'Aiuto';

  @override
  String get helpOnboardingLabel => 'Guarda di nuovo l\'introduzione';

  @override
  String get helpReportErrorLabel => 'Segnala un errore';

  @override
  String get helpImproveTranslationLabel => 'Migliora la traduzione';

  @override
  String get onboardingGreetingTitle => 'Ciao!';

  @override
  String get onboardingGreetingDescription => 'Siamo felici che tu sia qui e che voglia fare la tua parte per migliorare il trasporto pubblico.';

  @override
  String get onboardingGreetingButton => 'Ecco come funziona';

  @override
  String get onboardingSurveyingTitle => 'Dai un\'occhiata';

  @override
  String get onboardingSurveyingDescription => 'Vai a una fermata vicina per controllare il suo stato attuale.';

  @override
  String get onboardingSurveyingButton => 'Lo farò';

  @override
  String get onboardingAnsweringTitle => 'Ora tocca a te';

  @override
  String get onboardingAnsweringDescription => 'Per collezionare dati, seleziona un punto nell\'app e rispondi alle domande mostrate.';

  @override
  String get onboardingAnsweringButton => 'Okay, capito';

  @override
  String get onboardingContributingTitle => 'Condividere è importante';

  @override
  String get onboardingContributingDescription => 'Carica le tue risposte su OpenStreetMap per condividerle con il mondo intero.';

  @override
  String get onboardingContributingButton => 'Andiamo';

  @override
  String get privacyPolicyTitle => 'Informativa sulla privacy';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsProfessionalQuestionsLabel => 'Mostra domande avanzate';

  @override
  String get settingsProfessionalQuestionsDescription => 'Per motivi di sicurezza sono solo per utenti esperti';

  @override
  String get settingsThemeLabel => 'Schema di colore dell\'app';

  @override
  String get settingsThemeDialogTitle => 'Seleziona tema';

  @override
  String get settingsThemeOptionSystem => 'Impostazioni di sistema';

  @override
  String get settingsThemeOptionLight => 'Chiaro';

  @override
  String get settingsThemeOptionDark => 'Scuro';

  @override
  String get logoutDialogTitle => 'Uscire da OSM?';

  @override
  String get logoutDialogDescription => 'Se esci dall\'account, non potrai più caricare le modifiche su OpenStreetMap.';

  @override
  String get loginHint => 'Accedi al tuo account OpenStreetMap per caricare le tue modifiche.';

  @override
  String get numberInputPlaceholder => 'Inserisci qui…';

  @override
  String get numberInputFallbackName => 'Valore';

  @override
  String get numberInputValidationError => 'Numero non valido';

  @override
  String numberInputValidationErrorMax(String nameString, num max, String unit) {
    return '$nameString deve essere meno di $max$unit.';
  }

  @override
  String numberInputValidationErrorMin(String nameString, num min, String unit) {
    return '$nameString deve essere maggiore di $min$unit.';
  }

  @override
  String get stringInputPlaceholder => 'Inserisci qui…';

  @override
  String get stringInputValidationErrorMin => 'Dato troppo breve';

  @override
  String changesetCommentMessage(String mapFeaturesString, String stopsString) {
    return 'Aggiunti dettagli a $mapFeaturesString nella fermata $stopsString.';
  }

  @override
  String get changesetCommentConjunctionString => 'e';

  @override
  String get uploadMessageSuccess => 'Modifiche caricate con successo.';

  @override
  String get uploadMessageServerConnectionError => 'Errore: nessuna connessione al server OSM.';

  @override
  String get uploadMessageUnknownConnectionError => 'Errore sconosciuto durante la trasmissione.';

  @override
  String get queryMessageServerUnavailableError => 'Servizio non disponibile o sovraccarico. Riprova più tardi.';

  @override
  String get queryMessageTooManyRequestsError => 'Troppe richieste al server.';

  @override
  String get queryMessageConnectionTimeoutError => 'Errore: il server ha impiegato troppo tempo per rispondere.';

  @override
  String get queryMessageReceiveTimeoutError => 'Errore: troppo tempo per ricevere i dati.';

  @override
  String get queryMessageUnknownServerCommunicationError => 'Errore sconosciuto durante la comunicazione col server.';

  @override
  String get queryMessageUnknownError => 'Errore sconosciuto.';

  @override
  String questionnaireSummaryDedicatedMessage(String userName) {
    return 'Grazie $userName per le tue risposte.\nPer favore, controllale prima di caricare.';
  }

  @override
  String get questionnaireSummaryUndedicatedMessage => 'Grazie per le tue risposte.\nPer favore controllale prima di caricarle.';

  @override
  String get back => 'Indietro';

  @override
  String get next => 'Successiva';

  @override
  String get cancel => 'Annulla';

  @override
  String get confirm => 'Conferma';

  @override
  String get finish => 'Termina';

  @override
  String get login => 'Accedi';

  @override
  String get logout => 'Esci';

  @override
  String get skip => 'Salta';

  @override
  String get yes => 'Sì';

  @override
  String get no => 'No';

  @override
  String days(num day) {
    String _temp0 = intl.Intl.pluralLogic(
      day,
      locale: localeName,
      other: '$day giorni',
      one: '1 giorno',
    );
    return '$_temp0';
  }

  @override
  String hours(num hour) {
    String _temp0 = intl.Intl.pluralLogic(
      hour,
      locale: localeName,
      other: '$hour ore',
      one: '1 ora',
    );
    return '$_temp0';
  }

  @override
  String minutes(num minute) {
    String _temp0 = intl.Intl.pluralLogic(
      minute,
      locale: localeName,
      other: '$minute minuti',
      one: '1 minuto',
    );
    return '$_temp0';
  }

  @override
  String seconds(num second) {
    String _temp0 = intl.Intl.pluralLogic(
      second,
      locale: localeName,
      other: '$second secondi',
      one: '1 secondo',
    );
    return '$_temp0';
  }

  @override
  String get and => 'e';

  @override
  String get more => 'altro';

  @override
  String get element => 'elemento';

  @override
  String get durationInputDaysLabel => 'giorni';

  @override
  String get durationInputHoursLabel => 'ore';

  @override
  String get durationInputMinutesLabel => 'minuti';

  @override
  String get durationInputSecondsLabel => 'secondi';

  @override
  String get osmCreditsText => 'Dati © Collaboratori di OpenStreetMap';

  @override
  String changesetWithStopNameText(String elements, String stopArea) {
    return 'Aggiunti dettagli a $elements alla fermata $stopArea.';
  }

  @override
  String changesetWithoutStopNameText(String elements) {
    return 'Aggiunti dettagli a $elements nella fermata.';
  }

  @override
  String get mapFeatureBusStop => 'Fermata dell\'autobus';

  @override
  String get mapFeatureTramStop => 'Fermata del tram';

  @override
  String get mapFeatureTrainPlatform => 'Banchina tranviaria';

  @override
  String get mapFeaturePlatform => 'Banchina';

  @override
  String get mapFeatureStopPole => 'Fermata';

  @override
  String get mapFeatureStation => 'Stazione';

  @override
  String get mapFeatureTicketSalesPoint => 'Punto vendita biglietti';

  @override
  String get mapFeatureInformationPoint => 'Punto informazioni';

  @override
  String get mapFeatureStationMap => 'Mappa della stazione/fermata';

  @override
  String get mapFeatureTicketMachine => 'Macchinetta per i biglietti';

  @override
  String get mapFeatureParkingSpot => 'Parcheggio';

  @override
  String get mapFeatureTaxiStand => 'Fermata taxi';

  @override
  String get mapFeatureToilets => 'Bagni';

  @override
  String get mapFeatureLuggageLockers => 'Armadietti per bagagli';

  @override
  String get mapFeatureLuggageTransport => 'Trasporto bagagli';

  @override
  String get mapFeatureInformationTerminal => 'Terminale per informazioni';

  @override
  String get mapFeatureInformationCallPoint => 'Colonna informazioni';

  @override
  String get mapFeatureHelpPoint => 'Punto aiuto';

  @override
  String get mapFeatureEmergencyCallPoint => 'Punto per chiamate di emergenza';

  @override
  String get mapFeatureEntrance => 'Entrata';

  @override
  String get mapFeatureFootpath => 'Percorso pedonale';

  @override
  String get mapFeatureCyclePath => 'Cycle path';

  @override
  String get mapFeatureFootAndCyclePath => 'Foot & cycle path';

  @override
  String get mapFeatureStairs => 'Scale';

  @override
  String get mapFeatureElevator => 'Ascensore';

  @override
  String get mapFeatureEscalator => 'Scala mobile';

  @override
  String get mapFeatureCycleBarrier => 'Barriera per biciclette';

  @override
  String get mapFeatureCrossing => 'Attraversamento';

  @override
  String get mapFeatureTramCrossing => 'Attraversamento tranviario';

  @override
  String get mapFeatureRailroadCrossing => 'Attraversamento ferroviario';

  @override
  String get mapFeatureFootwayCrossing => 'Attraversamento pedonale';

  @override
  String get mapFeatureCyclewayCrossing => 'Attraversamento ciclabile';

  @override
  String get mapFeatureCurb => 'Cordolo';

  @override
  String get mapFeaturePedestrianLights => 'Semaforo pedonale';

  @override
  String mapFeatureBusPlatformNumber(String number) {
    return 'Binario: $number';
  }

  @override
  String mapFeatureTrainPlatformNumber(String number) {
    return 'Binario: $number';
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
