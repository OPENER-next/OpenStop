// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get aboutTitle => 'À propos';

  @override
  String get aboutSlogan => 'Prochain arrêt : Accessibilité';

  @override
  String get aboutVersionLabel => 'Version';

  @override
  String get aboutAuthorsLabel => 'Équipe';

  @override
  String aboutAuthorsDescription(String appName) {
    return 'Équipe de $appName';
  }

  @override
  String get aboutPrivacyPolicyLabel => 'Vie privée';

  @override
  String get aboutIdeaLabel => 'Idée';

  @override
  String get aboutIdeaDescription => 'Université de technologie de Chemnitz\nProfessorat de circuiterie et design système';

  @override
  String get aboutLicenseLabel => 'Licence';

  @override
  String get aboutLicensePackageLabel => 'Licences des paquets utilisés';

  @override
  String get aboutSourceCodeLabel => 'Code source';

  @override
  String get helpTitle => 'Aide';

  @override
  String get helpOnboardingLabel => 'Revoir l\'introduction';

  @override
  String get helpReportErrorLabel => 'Signaler une erreur';

  @override
  String get helpImproveTranslationLabel => 'Améliorer la traduction';

  @override
  String get onboardingGreetingTitle => 'Hey !';

  @override
  String get onboardingGreetingDescription => 'Merci d\'être là, et de vouloir œuvrer à l\'amélioration des transports en communs.';

  @override
  String get onboardingGreetingButton => 'Voilà comment ça marche';

  @override
  String get onboardingSurveyingTitle => 'Jeter un coup d\'œil';

  @override
  String get onboardingSurveyingDescription => 'Va à un arrêt proche pour vérifier son état.';

  @override
  String get onboardingSurveyingButton => 'Je m\'en occupe';

  @override
  String get onboardingAnsweringTitle => 'À toi maintenant';

  @override
  String get onboardingAnsweringDescription => 'Pour collecter des données, sélectionne un marqueur dans l\'application, et répond aux questions affichées.';

  @override
  String get onboardingAnsweringButton => 'Compris';

  @override
  String get onboardingContributingTitle => 'Partager le bonheur';

  @override
  String get onboardingContributingDescription => 'Partage tes réponses sur OpenStreetMap pour les diffuser aux monde entier.';

  @override
  String get onboardingContributingButton => 'Allons-y';

  @override
  String get privacyPolicyTitle => 'Vie privée';

  @override
  String get settingsTitle => 'Options';

  @override
  String get settingsProfessionalQuestionsLabel => 'Afficher les questions expertes';

  @override
  String get settingsProfessionalQuestionsDescription => 'Pour des raisons de sécurité, réservées aux professionnels';

  @override
  String get settingsThemeLabel => 'Thème de l\'application';

  @override
  String get settingsThemeDialogTitle => 'Sélectionner un thème';

  @override
  String get settingsThemeOptionSystem => 'Paramètres système';

  @override
  String get settingsThemeOptionLight => 'Clair';

  @override
  String get settingsThemeOptionDark => 'Sombre';

  @override
  String get logoutDialogTitle => 'Se déconnecter d\'OSM ?';

  @override
  String get logoutDialogDescription => 'Sans compte, il sera impossible de partager les modifications sur OpenStreetMap.';

  @override
  String get loginHint => 'Connecte toi à ton compte OpenStreetMap pour partager tes modifications.';

  @override
  String get numberInputPlaceholder => 'Entrer ici…';

  @override
  String get numberInputFallbackName => 'Valeur';

  @override
  String get numberInputValidationError => 'Nombre invalide';

  @override
  String numberInputValidationErrorMax(String nameString, num max, String unit) {
    return '$nameString doit être inférieur à $max$unit.';
  }

  @override
  String numberInputValidationErrorMin(String nameString, num min, String unit) {
    return '$nameString doit être supérieur à $min$unit.';
  }

  @override
  String get stringInputPlaceholder => 'Saisir ici…';

  @override
  String get stringInputValidationErrorMin => 'Valeur trop courte';

  @override
  String changesetCommentMessage(String mapFeaturesString, String stopsString) {
    return 'Ajout de détails sur $mapFeaturesString à l\'arrêt $stopsString.';
  }

  @override
  String get changesetCommentConjunctionString => 'et';

  @override
  String get uploadMessageSuccess => 'Partage des modifications réussi.';

  @override
  String get uploadMessageServerConnectionError => 'Erreur : Pas de connexion au serveur OSM.';

  @override
  String get uploadMessageUnknownConnectionError => 'Erreur inconnue durant la transmission.';

  @override
  String get queryMessageServerUnavailableError => 'Serveur indisponible ou surchargé. Veuillez réessayer plus tard.';

  @override
  String get queryMessageTooManyRequestsError => 'Trop de requêtes au serveur.';

  @override
  String get queryMessageConnectionTimeoutError => 'Erreur : Délai de requête serveur dépassé.';

  @override
  String get queryMessageReceiveTimeoutError => 'Erreur : Délai de réception dépassé.';

  @override
  String get queryMessageUnknownServerCommunicationError => 'Erreur inconnue durant la communication avec le serveur.';

  @override
  String get queryMessageUnknownError => 'Erreur inconnue.';

  @override
  String questionnaireSummaryDedicatedMessage(String userName) {
    return 'Merci pour ton aide $userName.\nVérifie les données avant de les diffuser.';
  }

  @override
  String get questionnaireSummaryUndedicatedMessage => 'Merci pour ton aide.\nVérifie les données avant de les diffuser.';

  @override
  String get back => 'Retour';

  @override
  String get next => 'Suivant';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get finish => 'Terminer';

  @override
  String get login => 'Connexion';

  @override
  String get logout => 'Déconnexion';

  @override
  String get skip => 'Passer';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String days(num day) {
    String _temp0 = intl.Intl.pluralLogic(
      day,
      locale: localeName,
      other: '$day jours',
      one: '1 jour',
    );
    return '$_temp0';
  }

  @override
  String hours(num hour) {
    String _temp0 = intl.Intl.pluralLogic(
      hour,
      locale: localeName,
      other: '$hour heures',
      one: '1 heure',
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
      other: '$second secondes',
      one: '1 seconde',
    );
    return '$_temp0';
  }

  @override
  String get and => 'et';

  @override
  String get more => 'plus';

  @override
  String get element => 'élément';

  @override
  String get durationInputDaysLabel => 'jours';

  @override
  String get durationInputHoursLabel => 'heures';

  @override
  String get durationInputMinutesLabel => 'minutes';

  @override
  String get durationInputSecondsLabel => 'secondes';

  @override
  String get osmCreditsText => 'Données © Contributeurs et contributrices OpenStreetMap';

  @override
  String changesetWithStopNameText(String elements, String stopArea) {
    return 'Ajout de détails sur $elements à l\'arrêt $stopArea.';
  }

  @override
  String changesetWithoutStopNameText(String elements) {
    return 'Ajout de détails sur $elements à l\'arrêt.';
  }

  @override
  String get mapFeatureBusStop => 'Arrêt de bus';

  @override
  String get mapFeatureTramStop => 'Arrêt de tramway';

  @override
  String get mapFeatureTrainPlatform => 'Quai de train';

  @override
  String get mapFeaturePlatform => 'Quai';

  @override
  String get mapFeatureStopPole => 'Point d\'arrêt';

  @override
  String get mapFeatureStation => 'Station';

  @override
  String get mapFeatureTicketSalesPoint => 'Billetterie';

  @override
  String get mapFeatureInformationPoint => 'Point d\'informations';

  @override
  String get mapFeatureStationMap => 'Carte de Station/Arrêt';

  @override
  String get mapFeatureTicketMachine => 'Machine à billets';

  @override
  String get mapFeatureParkingSpot => 'Zone de stationnement';

  @override
  String get mapFeatureTaxiStand => 'Arrêt de taxis';

  @override
  String get mapFeatureToilets => 'Toilettes';

  @override
  String get mapFeatureLuggageLockers => 'Casiers à bagages';

  @override
  String get mapFeatureLuggageTransport => 'Transport de bagages';

  @override
  String get mapFeatureInformationTerminal => 'Terminal d\'informations';

  @override
  String get mapFeatureInformationCallPoint => 'Colonne d\'informations';

  @override
  String get mapFeatureHelpPoint => 'Guichet d\'aide';

  @override
  String get mapFeatureEmergencyCallPoint => 'Zone d\'appel d\'urgence';

  @override
  String get mapFeatureEntrance => 'Entrée';

  @override
  String get mapFeatureFootpath => 'Cheminement piéton';

  @override
  String get mapFeatureCyclePath => 'Cycle path';

  @override
  String get mapFeatureFootAndCyclePath => 'Foot & cycle path';

  @override
  String get mapFeatureStairs => 'Escaliers';

  @override
  String get mapFeatureElevator => 'Ascenceur';

  @override
  String get mapFeatureEscalator => 'Escalator';

  @override
  String get mapFeatureCycleBarrier => 'Barrière';

  @override
  String get mapFeatureCrossing => 'Passage piéton';

  @override
  String get mapFeatureTramCrossing => 'Traversée de rails de tramway';

  @override
  String get mapFeatureRailroadCrossing => 'Traversée de rails de train';

  @override
  String get mapFeatureFootwayCrossing => 'Passage pour piétons';

  @override
  String get mapFeatureCyclewayCrossing => 'Passage pour cyclistes';

  @override
  String get mapFeatureCurb => 'Bordure';

  @override
  String get mapFeaturePedestrianLights => 'Feu piéton';

  @override
  String mapFeatureBusPlatformNumber(String number) {
    return 'Quai : $number';
  }

  @override
  String mapFeatureTrainPlatformNumber(String number) {
    return 'Quai : $number';
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
