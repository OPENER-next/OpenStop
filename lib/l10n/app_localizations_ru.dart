// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get aboutTitle => 'О приложении';

  @override
  String get aboutSlogan => 'Следующая остановка — Доступность';

  @override
  String get aboutVersionLabel => 'Версия';

  @override
  String get aboutAuthorsLabel => 'Авторы';

  @override
  String aboutAuthorsDescription(String appName) {
    return 'Внёсшие вклад в разработку $appName';
  }

  @override
  String get aboutPrivacyPolicyLabel => 'Политика конфиденциальности';

  @override
  String get aboutIdeaLabel => 'Авторы идеи';

  @override
  String get aboutIdeaDescription => 'Хемницкий технологический университет\nПрофессорское проектирование схем и систем';

  @override
  String get aboutLicenseLabel => 'Лицензия';

  @override
  String get aboutLicensePackageLabel => 'Лицензии используемых компонентов';

  @override
  String get aboutSourceCodeLabel => 'Исходный код';

  @override
  String get helpTitle => 'Помощь';

  @override
  String get helpOnboardingLabel => 'Посмотреть онбординг ещё раз';

  @override
  String get helpReportErrorLabel => 'Сообщить об ошибке';

  @override
  String get helpImproveTranslationLabel => 'Помочь перевести приложение';

  @override
  String get onboardingGreetingTitle => 'Привет!';

  @override
  String get onboardingGreetingDescription => 'Мы рады, что вы здесь и хотите внести вклад в улучшении общественного транспорта.';

  @override
  String get onboardingGreetingButton => 'Вот как это работает';

  @override
  String get onboardingSurveyingTitle => 'Осмотритесь';

  @override
  String get onboardingSurveyingDescription => 'Подойдите к ближайшей остановке, чтобы оценить её состояние.';

  @override
  String get onboardingSurveyingButton => 'Я сделаю это';

  @override
  String get onboardingAnsweringTitle => 'Теперь ваш ход';

  @override
  String get onboardingAnsweringDescription => 'Чтобы собрать данные, выберите маркер на карте и отвечайте на вопросы.';

  @override
  String get onboardingAnsweringButton => 'Ладно, понятно';

  @override
  String get onboardingContributingTitle => 'Делиться — значит заботиться';

  @override
  String get onboardingContributingDescription => 'Ваши ответы будут загружены в OpenStreetMap, чтобы их мог увидеть весь мир.';

  @override
  String get onboardingContributingButton => 'Начнём же';

  @override
  String get privacyPolicyTitle => 'Политика конфиденциальности';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsProfessionalQuestionsLabel => 'Отображать сложные вопросы';

  @override
  String get settingsProfessionalQuestionsDescription => 'Из соображений безопасности предназначено только для профессионалов';

  @override
  String get settingsThemeLabel => 'Цветовая схема приложения';

  @override
  String get settingsThemeDialogTitle => 'Выбрать тему';

  @override
  String get settingsThemeOptionSystem => 'Как в системе';

  @override
  String get settingsThemeOptionLight => 'Светлая';

  @override
  String get settingsThemeOptionDark => 'Тёмная';

  @override
  String get logoutDialogTitle => 'Выйти из OSM?';

  @override
  String get logoutDialogDescription => 'После выхода из аккаунта, вы не сможете загружать изменения в OpenStreetMap.';

  @override
  String get loginHint => 'Войти в учётную запись OpenStreetMap, чтобы загрузить изменения.';

  @override
  String get numberInputPlaceholder => 'Вводите здесь…';

  @override
  String get numberInputFallbackName => 'Значение';

  @override
  String get numberInputValidationError => 'Неверный номер';

  @override
  String numberInputValidationErrorMax(String nameString, num max, String unit) {
    return '$nameString должен быть меньше $max$unit.';
  }

  @override
  String numberInputValidationErrorMin(String nameString, num min, String unit) {
    return '$nameString должен быть больше $min $unit.';
  }

  @override
  String get stringInputPlaceholder => 'Вводите здесь…';

  @override
  String get stringInputValidationErrorMin => 'Введенное слишком коротко';

  @override
  String changesetCommentMessage(String mapFeaturesString, String stopsString) {
    return 'Добавлены сведения о $mapFeaturesString про остановку $stopsString.';
  }

  @override
  String get changesetCommentConjunctionString => 'и';

  @override
  String get uploadMessageSuccess => 'Правки успешно отправлены.';

  @override
  String get uploadMessageServerConnectionError => 'Ошибка: Нет связи с сервером OSM.';

  @override
  String get uploadMessageUnknownConnectionError => 'Неизвестная ошибка во время передачи.';

  @override
  String get queryMessageServerUnavailableError => 'Сервер недоступен или перегружен. Попробуйте позже.';

  @override
  String get queryMessageTooManyRequestsError => 'Слишком много запросов к серверу.';

  @override
  String get queryMessageConnectionTimeoutError => 'Ошибка: таймаут ответа сервера.';

  @override
  String get queryMessageReceiveTimeoutError => 'Ошибка: таймаут получения данных.';

  @override
  String get queryMessageUnknownServerCommunicationError => 'Неизвестная ошибка при общении с сервером.';

  @override
  String get queryMessageUnknownError => 'Неизвестная ошибка.';

  @override
  String questionnaireSummaryDedicatedMessage(String userName) {
    return 'Спасибо, $userName, за ваши ответы.\nПожалуйста, проверьте их перед отправкой.';
  }

  @override
  String get questionnaireSummaryUndedicatedMessage => 'Спасибо за ваши ответы.\nПожалуйста, проверьте их перед отправкой.';

  @override
  String get back => 'Назад';

  @override
  String get next => 'Вперед';

  @override
  String get cancel => 'Отмена';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get finish => 'Завершить';

  @override
  String get login => 'Войти';

  @override
  String get logout => 'Выйти';

  @override
  String get skip => 'Пропустить';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

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
  String get and => 'и';

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
  String get mapFeatureBusStop => 'Автобусная остановка';

  @override
  String get mapFeatureTramStop => 'Трамвайная остановка';

  @override
  String get mapFeatureTrainPlatform => 'Платформа поезда';

  @override
  String get mapFeaturePlatform => 'Платформа';

  @override
  String get mapFeatureStopPole => 'Stop pole';

  @override
  String get mapFeatureStation => 'Станция';

  @override
  String get mapFeatureTicketSalesPoint => 'Место продажи билетов';

  @override
  String get mapFeatureInformationPoint => 'Информационный пункт';

  @override
  String get mapFeatureStationMap => 'Station/Stop map';

  @override
  String get mapFeatureTicketMachine => 'Ticket machine';

  @override
  String get mapFeatureParkingSpot => 'Parking spot';

  @override
  String get mapFeatureTaxiStand => 'Taxi stand';

  @override
  String get mapFeatureToilets => 'Туалеты';

  @override
  String get mapFeatureLuggageLockers => 'Камеры хранения';

  @override
  String get mapFeatureLuggageTransport => 'Luggage transport';

  @override
  String get mapFeatureInformationTerminal => 'Информационный треминал';

  @override
  String get mapFeatureInformationCallPoint => 'Стойка информации';

  @override
  String get mapFeatureHelpPoint => 'Help point';

  @override
  String get mapFeatureEmergencyCallPoint => 'Emergency call point';

  @override
  String get mapFeatureEntrance => 'Вход';

  @override
  String get mapFeatureFootpath => 'Footpath';

  @override
  String get mapFeatureCyclePath => 'Cycle path';

  @override
  String get mapFeatureFootAndCyclePath => 'Foot & cycle path';

  @override
  String get mapFeatureStairs => 'Лестницы';

  @override
  String get mapFeatureElevator => 'Лифт';

  @override
  String get mapFeatureEscalator => 'Эскалатор';

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
    return 'Платформа: $number';
  }

  @override
  String mapFeatureTrainPlatformNumber(String number) {
    return 'Платформа: $number';
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
