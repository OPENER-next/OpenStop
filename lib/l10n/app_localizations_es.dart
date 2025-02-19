// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get aboutTitle => 'Acerca de';

  @override
  String get aboutSlogan => 'Siguiente parada: Accesibilidad';

  @override
  String get aboutVersionLabel => 'Versión';

  @override
  String get aboutAuthorsLabel => 'Autores';

  @override
  String aboutAuthorsDescription(String appName) {
    return '$appName colaboradores';
  }

  @override
  String get aboutPrivacyPolicyLabel => 'Política de privacidad';

  @override
  String get aboutIdeaLabel => 'Idea';

  @override
  String get aboutIdeaDescription => 'Universidad Politécnica de Chemnitz\nCátedra de Diseño de Circuitos y Sistemas';

  @override
  String get aboutLicenseLabel => 'Licencia';

  @override
  String get aboutLicensePackageLabel => 'Licencias de paquetes usados';

  @override
  String get aboutSourceCodeLabel => 'Código fuente';

  @override
  String get helpTitle => 'Ayuda';

  @override
  String get helpOnboardingLabel => 'Mirar la introducción de nuevo';

  @override
  String get helpReportErrorLabel => 'Reportar un error';

  @override
  String get helpImproveTranslationLabel => 'Mejorar la traducción';

  @override
  String get onboardingGreetingTitle => '¡Ey!';

  @override
  String get onboardingGreetingDescription => 'Nos alegramos de que estés aquí y quieras aportar tu granito de arena para mejorar el transporte público.';

  @override
  String get onboardingGreetingButton => 'Así es como funciona';

  @override
  String get onboardingSurveyingTitle => 'Echa un vistazo';

  @override
  String get onboardingSurveyingDescription => 'Ve a una parada cercana para examinar su estado actual.';

  @override
  String get onboardingSurveyingButton => 'Lo haré';

  @override
  String get onboardingAnsweringTitle => 'Ahora es tu turno';

  @override
  String get onboardingAnsweringDescription => 'Para recopilar datos, selecciona un marcador en la aplicación y responde las preguntas que se muestran.';

  @override
  String get onboardingAnsweringButton => 'Vale, entendido';

  @override
  String get onboardingContributingTitle => 'Compartir es cuidar';

  @override
  String get onboardingContributingDescription => 'Sube tus respuestas a OpenStreetMap para compartirlas con todo el mundo.';

  @override
  String get onboardingContributingButton => 'Aquí vamos';

  @override
  String get privacyPolicyTitle => 'Política de privacidad';

  @override
  String get settingsTitle => 'Configuraciones';

  @override
  String get settingsProfessionalQuestionsLabel => 'Mostrar preguntas profesionales';

  @override
  String get settingsProfessionalQuestionsDescription => 'Por razones de seguridad solo destinadas a usuarios profesionales';

  @override
  String get settingsThemeLabel => 'Esquema de color de la aplicación';

  @override
  String get settingsThemeDialogTitle => 'Seleccione el tema';

  @override
  String get settingsThemeOptionSystem => 'Configuración del sistema';

  @override
  String get settingsThemeOptionLight => 'Claro';

  @override
  String get settingsThemeOptionDark => 'Oscuro';

  @override
  String get logoutDialogTitle => '¿Cerrar sesión de OSM?';

  @override
  String get logoutDialogDescription => 'Si cierras sesión, ya no puedes cargar cambios en OpenStreetMap.';

  @override
  String get loginHint => 'Iniciar sesión con tu cuenta OpenStreetMap para cargar tus cambios.';

  @override
  String get numberInputPlaceholder => 'Introducir aquí…';

  @override
  String get numberInputFallbackName => 'Valor';

  @override
  String get numberInputValidationError => 'Número inválido';

  @override
  String numberInputValidationErrorMax(String nameString, num max, String unit) {
    return '$nameString debe ser menor que $max $unit.';
  }

  @override
  String numberInputValidationErrorMin(String nameString, num min, String unit) {
    return '$nameString debe ser mayor que $min $unit.';
  }

  @override
  String get stringInputPlaceholder => 'Entrar aquí…';

  @override
  String get stringInputValidationErrorMin => 'Entrada demasiado corta';

  @override
  String changesetCommentMessage(String mapFeaturesString, String stopsString) {
    return 'Se agregaron detalles a $mapFeaturesString en el área de parada $stopsString.';
  }

  @override
  String get changesetCommentConjunctionString => 'y';

  @override
  String get uploadMessageSuccess => 'Cambios cargados con éxito.';

  @override
  String get uploadMessageServerConnectionError => 'Error: no hay conexión al servidor OSM.';

  @override
  String get uploadMessageUnknownConnectionError => 'Error desconocido durante la transmisión.';

  @override
  String get queryMessageServerUnavailableError => 'Servidor no disponible o sobrecargado. Inténtalo de nuevo más tarde.';

  @override
  String get queryMessageTooManyRequestsError => 'Demasiadas solicitudes al servidor.';

  @override
  String get queryMessageConnectionTimeoutError => 'Error: la consulta del servidor ha caducado.';

  @override
  String get queryMessageReceiveTimeoutError => 'Error: tiempo de recepción de datos agotado.';

  @override
  String get queryMessageUnknownServerCommunicationError => 'Error desconocido durante la comunicación con el servidor.';

  @override
  String get queryMessageUnknownError => 'Error desconocido.';

  @override
  String questionnaireSummaryDedicatedMessage(String userName) {
    return 'Gracias $userName por tus respuestas.\nPor favor verifícalas antes de cargar.';
  }

  @override
  String get questionnaireSummaryUndedicatedMessage => 'Gracias por tus respuestas.\nPor favor verifícalas antes de cargar.';

  @override
  String get back => 'Atrás';

  @override
  String get next => 'Siguiente';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get finish => 'Finalizar';

  @override
  String get login => 'Inicio de sesión';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get skip => 'Saltar';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String days(num day) {
    String _temp0 = intl.Intl.pluralLogic(
      day,
      locale: localeName,
      other: '$day días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String hours(num hour) {
    String _temp0 = intl.Intl.pluralLogic(
      hour,
      locale: localeName,
      other: '$hour horas',
      one: '1 hora',
    );
    return '$_temp0';
  }

  @override
  String minutes(num minute) {
    String _temp0 = intl.Intl.pluralLogic(
      minute,
      locale: localeName,
      other: '$minute minutos',
      one: '1 minuto',
    );
    return '$_temp0';
  }

  @override
  String seconds(num second) {
    String _temp0 = intl.Intl.pluralLogic(
      second,
      locale: localeName,
      other: '$second segundos',
      one: '1 segundo',
    );
    return '$_temp0';
  }

  @override
  String get and => 'y';

  @override
  String get more => 'más';

  @override
  String get element => 'elemento';

  @override
  String get durationInputDaysLabel => 'días';

  @override
  String get durationInputHoursLabel => 'horas';

  @override
  String get durationInputMinutesLabel => 'minutos';

  @override
  String get durationInputSecondsLabel => 'segundos';

  @override
  String get osmCreditsText => 'Datos © colaboradores de OpenStreetMap';

  @override
  String changesetWithStopNameText(String elements, String stopArea) {
    return 'Se agregaron detalles a $elements en el área de la parada $stopArea.';
  }

  @override
  String changesetWithoutStopNameText(String elements) {
    return 'Se agregaron detalles a $elements en el área de la parada.';
  }

  @override
  String get mapFeatureBusStop => 'Parada de autobús';

  @override
  String get mapFeatureTramStop => 'Parada de tranvía';

  @override
  String get mapFeatureTrainPlatform => 'Plataforma del tren';

  @override
  String get mapFeaturePlatform => 'Plataforma';

  @override
  String get mapFeatureStopPole => 'Punto de parada';

  @override
  String get mapFeatureStation => 'Estación terminal';

  @override
  String get mapFeatureTicketSalesPoint => 'Punto de venta de entradas';

  @override
  String get mapFeatureInformationPoint => 'Punto de información';

  @override
  String get mapFeatureStationMap => 'Mapa de la estacion/parada';

  @override
  String get mapFeatureTicketMachine => 'Máquina de tiquetes';

  @override
  String get mapFeatureParkingSpot => 'Plaza de aparcamiento';

  @override
  String get mapFeatureTaxiStand => 'Parada de taxi';

  @override
  String get mapFeatureToilets => 'Baños';

  @override
  String get mapFeatureLuggageLockers => 'Casilleros de equipaje';

  @override
  String get mapFeatureLuggageTransport => 'Transporte de equipaje';

  @override
  String get mapFeatureInformationTerminal => 'Terminal de información';

  @override
  String get mapFeatureInformationCallPoint => 'Columna de información';

  @override
  String get mapFeatureHelpPoint => 'Punto de ayuda';

  @override
  String get mapFeatureEmergencyCallPoint => 'Punto de llamada de emergencia';

  @override
  String get mapFeatureEntrance => 'Entrada';

  @override
  String get mapFeatureFootpath => 'Acera';

  @override
  String get mapFeatureCyclePath => 'Carril bici';

  @override
  String get mapFeatureFootAndCyclePath => 'Senda peatonal y ciclista';

  @override
  String get mapFeatureStairs => 'Escaleras';

  @override
  String get mapFeatureElevator => 'Ascensor';

  @override
  String get mapFeatureEscalator => 'Escalera mecánica';

  @override
  String get mapFeatureCycleBarrier => 'Barrera para bicicleta';

  @override
  String get mapFeatureCrossing => 'Paso peatonal';

  @override
  String get mapFeatureTramCrossing => 'Cruce de tranvía';

  @override
  String get mapFeatureRailroadCrossing => 'Cruce de ferrocarril';

  @override
  String get mapFeatureFootwayCrossing => 'Paso de peatones';

  @override
  String get mapFeatureCyclewayCrossing => 'Paso de bicicletas';

  @override
  String get mapFeatureCurb => 'Bordillo / sardinel';

  @override
  String get mapFeaturePedestrianLights => 'Semáforo para peatones';

  @override
  String mapFeatureBusPlatformNumber(String number) {
    return 'Plataforma: $number';
  }

  @override
  String mapFeatureTrainPlatformNumber(String number) {
    return 'Plataforma: $number';
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
