// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Belarusian (`be`).
class AppLocalizationsBe extends AppLocalizations {
  AppLocalizationsBe([String locale = 'be']) : super(locale);

  @override
  String get aboutTitle => 'Аб дадатку';

  @override
  String get aboutSlogan => 'Наступны прыпынак: Даступнасць';

  @override
  String get aboutVersionLabel => 'Версія';

  @override
  String get aboutAuthorsLabel => 'Аўтары';

  @override
  String aboutAuthorsDescription(String appName) {
    return '$appName удзельнікі';
  }

  @override
  String get aboutPrivacyPolicyLabel => 'Палітыка прыватнасці';

  @override
  String get aboutIdeaLabel => 'Ідэя';

  @override
  String get aboutIdeaDescription => 'Хемніцкі тэхналагічны універсітэт\nПраектаванне схем і сістэм';

  @override
  String get aboutLicenseLabel => 'Ліцэнзія';

  @override
  String get aboutLicensePackageLabel => 'Ліцэнзіі выкарыстаных пакетаў';

  @override
  String get aboutSourceCodeLabel => 'Зыходны код';

  @override
  String get helpTitle => 'Дапамога';

  @override
  String get helpOnboardingLabel => 'Паглядзіце ўвядзенне яшчэ раз';

  @override
  String get helpReportErrorLabel => 'Паведаміць пра памылку';

  @override
  String get helpImproveTranslationLabel => 'Палепшыць пераклад';

  @override
  String get onboardingGreetingTitle => 'Прывітанне!';

  @override
  String get onboardingGreetingDescription => 'Мы рады, што вы тут і хочаце ўнесці свой уклад у паляпшэнне грамадскага транспарту.';

  @override
  String get onboardingGreetingButton => 'Вось як гэта працуе';

  @override
  String get onboardingSurveyingTitle => 'Паглядзі';

  @override
  String get onboardingSurveyingDescription => 'Падыйдзіце да бліжэйшага прыпынку, каб аглядзець яго бягучы стан.';

  @override
  String get onboardingSurveyingButton => 'Я зраблю гэта';

  @override
  String get onboardingAnsweringTitle => 'Цяпер твая чарга';

  @override
  String get onboardingAnsweringDescription => 'Для збору даных выберыце маркер у дадатку і адкажыце на паказаныя пытанні.';

  @override
  String get onboardingAnsweringButton => 'Добра, зразумела';

  @override
  String get onboardingContributingTitle => 'Абмен - гэта клопат';

  @override
  String get onboardingContributingDescription => 'Загрузіце свае адказы ў OpenStreetMap, каб падзяліцца імі з усім светам.';

  @override
  String get onboardingContributingButton => 'Пачынаем';

  @override
  String get privacyPolicyTitle => 'Палітыка прыватнасці';

  @override
  String get settingsTitle => 'Налады';

  @override
  String get settingsProfessionalQuestionsLabel => 'Паказаць прафесійныя пытанні';

  @override
  String get settingsProfessionalQuestionsDescription => 'З меркаванняў бяспекі прызначаны толькі для прафесіяналаў';

  @override
  String get settingsThemeLabel => 'Каляровая схема прыкладання';

  @override
  String get settingsThemeDialogTitle => 'Выбраць тэму';

  @override
  String get settingsThemeOptionSystem => 'Сістэмныя налады';

  @override
  String get settingsThemeOptionLight => 'Светлая';

  @override
  String get settingsThemeOptionDark => 'Цёмная';

  @override
  String get logoutDialogTitle => 'Выйсці з OSM?';

  @override
  String get logoutDialogDescription => 'Калі вы выйдзеце, вы больш не зможаце загружаць змены ў OpenStreetMap.';

  @override
  String get loginHint => 'Увайдзіце ў свой уліковы запіс OpenStreetMap, каб загрузіць змены.';

  @override
  String get numberInputPlaceholder => 'Увядзіце сюды…';

  @override
  String get numberInputFallbackName => 'Значэнне';

  @override
  String get numberInputValidationError => 'Няправільны нумар';

  @override
  String numberInputValidationErrorMax(String nameString, num max, String unit) {
    return '$nameString павінна быць менш $max$unit.';
  }

  @override
  String numberInputValidationErrorMin(String nameString, num min, String unit) {
    return '$nameString павінна быць больш, чым $min$unit.';
  }

  @override
  String get stringInputPlaceholder => 'Увядзіце тут…';

  @override
  String get stringInputValidationErrorMin => 'Занадта кароткае';

  @override
  String changesetCommentMessage(String mapFeaturesString, String stopsString) {
    return 'Дададзены дэталі да $mapFeaturesString у зоне прыпынку $stopsString.';
  }

  @override
  String get changesetCommentConjunctionString => 'і';

  @override
  String get uploadMessageSuccess => 'Змены паспяхова запампаваны.';

  @override
  String get uploadMessageServerConnectionError => 'Памылка: Няма злучэння з серверам OSM.';

  @override
  String get uploadMessageUnknownConnectionError => 'Невядомая памылка падчас перадачы.';

  @override
  String get queryMessageServerUnavailableError => 'Сервер недаступны або перагружаны. Паўтарыце спробу пазней.';

  @override
  String get queryMessageTooManyRequestsError => 'Занадта шмат запытаў на сервер.';

  @override
  String get queryMessageConnectionTimeoutError => 'Памылка: час чакання запыту сервера скончыўся.';

  @override
  String get queryMessageReceiveTimeoutError => 'Памылка: час атрымання дадзеных скончыўся.';

  @override
  String get queryMessageUnknownServerCommunicationError => 'Невядомая памылка падчас сувязі з серверам.';

  @override
  String get queryMessageUnknownError => 'Невядомая памылка.';

  @override
  String questionnaireSummaryDedicatedMessage(String userName) {
    return 'Дзякуй $userName за вашыя адказы.\nПраверце іх перад загрузкай.';
  }

  @override
  String get questionnaireSummaryUndedicatedMessage => 'Дзякуй за адказы.\nПраверце іх перад загрузкай.';

  @override
  String get back => 'Назад';

  @override
  String get next => 'Наступны';

  @override
  String get cancel => 'Адмена';

  @override
  String get confirm => 'Пацвердзіць';

  @override
  String get finish => 'Гатова';

  @override
  String get login => 'Увайсці';

  @override
  String get logout => 'Выйсці';

  @override
  String get skip => 'Прапусціць';

  @override
  String get yes => 'Так';

  @override
  String get no => 'Не';

  @override
  String days(num day) {
    String _temp0 = intl.Intl.pluralLogic(
      day,
      locale: localeName,
      other: '$day дзён',
      one: '1 дзень',
    );
    return '$_temp0';
  }

  @override
  String hours(num hour) {
    String _temp0 = intl.Intl.pluralLogic(
      hour,
      locale: localeName,
      other: '$hour гадзін',
      one: '1 час',
    );
    return '$_temp0';
  }

  @override
  String minutes(num minute) {
    String _temp0 = intl.Intl.pluralLogic(
      minute,
      locale: localeName,
      other: '$minute хвілін',
      one: '1 хвіліна',
    );
    return '$_temp0';
  }

  @override
  String seconds(num second) {
    String _temp0 = intl.Intl.pluralLogic(
      second,
      locale: localeName,
      other: '$second секунд',
      one: '1 секунда',
    );
    return '$_temp0';
  }

  @override
  String get and => 'і';

  @override
  String get more => 'больш';

  @override
  String get element => 'назва';

  @override
  String get durationInputDaysLabel => 'дні';

  @override
  String get durationInputHoursLabel => 'гадзіны';

  @override
  String get durationInputMinutesLabel => 'хвіліны';

  @override
  String get durationInputSecondsLabel => 'секунд';

  @override
  String get osmCreditsText => 'Дадзеныя ўдзельнікаў ©OpenStreetMap';

  @override
  String changesetWithStopNameText(String elements, String stopArea) {
    return 'Дададзены дэталі да $elements у зоне прыпынку $stopArea.';
  }

  @override
  String changesetWithoutStopNameText(String elements) {
    return 'Дададзены дэталі да $elements у зоне прыпынку.';
  }

  @override
  String get mapFeatureBusStop => 'Аўтобусны прыпынак';

  @override
  String get mapFeatureTramStop => 'Трамвайны прыпынак';

  @override
  String get mapFeatureTrainPlatform => 'Платформа цягніка';

  @override
  String get mapFeaturePlatform => 'Платформа';

  @override
  String get mapFeatureStopPole => 'Знак стоп';

  @override
  String get mapFeatureStation => 'Станцыя';

  @override
  String get mapFeatureTicketSalesPoint => 'Пункт продажу білетаў';

  @override
  String get mapFeatureInformationPoint => 'Інфармацыйны пункт';

  @override
  String get mapFeatureStationMap => 'Мапа станцыі/прыпынку';

  @override
  String get mapFeatureTicketMachine => 'Аўтамат па продажы білетаў';

  @override
  String get mapFeatureParkingSpot => 'Паркоўка';

  @override
  String get mapFeatureTaxiStand => 'Стаянка таксі';

  @override
  String get mapFeatureToilets => 'Прыбіральні';

  @override
  String get mapFeatureLuggageLockers => 'Камера захоўвання';

  @override
  String get mapFeatureLuggageTransport => 'Перавоз багажу';

  @override
  String get mapFeatureInformationTerminal => 'Інфармацыйны тэрмінал';

  @override
  String get mapFeatureInformationCallPoint => 'Інфармацыйная калонка';

  @override
  String get mapFeatureHelpPoint => 'Пункт дапамогі';

  @override
  String get mapFeatureEmergencyCallPoint => 'Пункт экстранага выкліку';

  @override
  String get mapFeatureEntrance => 'Уваход';

  @override
  String get mapFeatureFootpath => 'Пешаходная дарожка';

  @override
  String get mapFeatureCyclePath => 'Cycle path';

  @override
  String get mapFeatureFootAndCyclePath => 'Foot & cycle path';

  @override
  String get mapFeatureStairs => 'Лесвіцы';

  @override
  String get mapFeatureElevator => 'Ліфт';

  @override
  String get mapFeatureEscalator => 'Эскалатар';

  @override
  String get mapFeatureCycleBarrier => 'Веласіпедны бар\'ер';

  @override
  String get mapFeatureCrossing => 'Пераход';

  @override
  String get mapFeatureTramCrossing => 'Трамвайны пераезд';

  @override
  String get mapFeatureRailroadCrossing => 'Чыгуначны пераезд';

  @override
  String get mapFeatureFootwayCrossing => 'Пешаходны пераход';

  @override
  String get mapFeatureCyclewayCrossing => 'Веласіпедны пераход';

  @override
  String get mapFeatureCurb => 'Бардзюр';

  @override
  String get mapFeaturePedestrianLights => 'Пешаходны святлафор';

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
