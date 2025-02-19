// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutSlogan => 'Next stop: Accessibility';

  @override
  String get aboutVersionLabel => 'Version';

  @override
  String get aboutAuthorsLabel => 'Authors';

  @override
  String aboutAuthorsDescription(String appName) {
    return '$appName contributors';
  }

  @override
  String get aboutPrivacyPolicyLabel => 'Privacy Policy';

  @override
  String get aboutIdeaLabel => 'Idea';

  @override
  String get aboutIdeaDescription => 'Chemnitz University of Technology\nProfessorship Circuit and System Design';

  @override
  String get aboutLicenseLabel => 'License';

  @override
  String get aboutLicensePackageLabel => 'Licenses of used packages';

  @override
  String get aboutSourceCodeLabel => 'Source code';

  @override
  String get helpTitle => 'Help';

  @override
  String get helpOnboardingLabel => 'Watch the introduction again';

  @override
  String get helpReportErrorLabel => 'Report an error';

  @override
  String get helpImproveTranslationLabel => 'Improve the translation';

  @override
  String get onboardingGreetingTitle => 'Hey!';

  @override
  String get onboardingGreetingDescription => 'We\'re glad you\'re here and want to do your part to improve public transport.';

  @override
  String get onboardingGreetingButton => 'Here\'s how it works';

  @override
  String get onboardingSurveyingTitle => 'Take a look';

  @override
  String get onboardingSurveyingDescription => 'Go to a nearby stop to survey its current state.';

  @override
  String get onboardingSurveyingButton => 'I\'ll do it';

  @override
  String get onboardingAnsweringTitle => 'Now it\'s your turn';

  @override
  String get onboardingAnsweringDescription => 'In order to collect data select a marker in the app and answer the displayed questions.';

  @override
  String get onboardingAnsweringButton => 'Okay, got it';

  @override
  String get onboardingContributingTitle => 'Sharing is caring';

  @override
  String get onboardingContributingDescription => 'Upload your answers to OpenStreetMap to share them with the whole world.';

  @override
  String get onboardingContributingButton => 'Here we go';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsProfessionalQuestionsLabel => 'Display Professional Questions';

  @override
  String get settingsProfessionalQuestionsDescription => 'For safety reasons only intended for professionals';

  @override
  String get settingsThemeLabel => 'Color Scheme of the App';

  @override
  String get settingsThemeDialogTitle => 'Select theme';

  @override
  String get settingsThemeOptionSystem => 'System Setting';

  @override
  String get settingsThemeOptionLight => 'Light';

  @override
  String get settingsThemeOptionDark => 'Dark';

  @override
  String get logoutDialogTitle => 'Log out of OSM?';

  @override
  String get logoutDialogDescription => 'If you log out, you can no longer upload changes to OpenStreetMap.';

  @override
  String get loginHint => 'Log in with your OpenStreetMap account to upload your changes.';

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

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans(): super('zh_Hans');

  @override
  String get aboutTitle => '关于';

  @override
  String get aboutSlogan => '下一站：无障碍';

  @override
  String get aboutVersionLabel => '版本';

  @override
  String get aboutAuthorsLabel => '作者';

  @override
  String aboutAuthorsDescription(String appName) {
    return '$appName贡献者';
  }

  @override
  String get aboutPrivacyPolicyLabel => '隐私政策';

  @override
  String get aboutIdeaLabel => '想法';

  @override
  String get aboutIdeaDescription => '开姆尼茨工业大学\n电路与系统设计教职';

  @override
  String get aboutLicenseLabel => '许可证';

  @override
  String get aboutLicensePackageLabel => '所用的包的许可证';

  @override
  String get aboutSourceCodeLabel => '源代码';

  @override
  String get helpTitle => '帮助';

  @override
  String get helpOnboardingLabel => '重新播放介绍';

  @override
  String get helpReportErrorLabel => '报告错误';

  @override
  String get onboardingGreetingTitle => '嘿！';

  @override
  String get onboardingGreetingDescription => '我们很高兴您来到这里，并希望为改善公共交通尽自己的一份力量。';

  @override
  String get onboardingGreetingButton => '了解如何工作';

  @override
  String get onboardingSurveyingTitle => '多加留心';

  @override
  String get onboardingSurveyingDescription => '前往附近的车站调查其当前状况。';

  @override
  String get onboardingSurveyingButton => '我会尽力';

  @override
  String get onboardingAnsweringTitle => '现在是您的回合';

  @override
  String get onboardingAnsweringDescription => '为了收集数据，请在应用程序中选择一个标记并回答显示的问题。';

  @override
  String get onboardingAnsweringButton => '好的，明白';

  @override
  String get onboardingContributingTitle => '分享即关爱';

  @override
  String get onboardingContributingDescription => '将您的回答上传到OpenStreetMap，与全世界分享。';

  @override
  String get onboardingContributingButton => '我们开始吧！';

  @override
  String get privacyPolicyTitle => '隐私政策';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsProfessionalQuestionsLabel => '显示专业问题';

  @override
  String get settingsProfessionalQuestionsDescription => '出于安全原因，仅限专业人士使用';

  @override
  String get settingsThemeLabel => 'APP颜色主题';

  @override
  String get settingsThemeDialogTitle => '选择主题';

  @override
  String get settingsThemeOptionSystem => '跟随系统设置';

  @override
  String get settingsThemeOptionLight => '亮色';

  @override
  String get settingsThemeOptionDark => '暗色';

  @override
  String get logoutDialogTitle => '登出OSM？';

  @override
  String get logoutDialogDescription => '如果您登出，则无法再将更改上传到 OpenStreetMap。';

  @override
  String get loginHint => '使用您的 OpenStreetMap 账户登入以上传您的更改。';

  @override
  String get numberInputPlaceholder => '在这里输入……';

  @override
  String get numberInputFallbackName => '值';

  @override
  String get numberInputValidationError => '无效的数字';

  @override
  String numberInputValidationErrorMax(String nameString, num max, String unit) {
    return '$nameString 必须小于 $max$unit.';
  }

  @override
  String numberInputValidationErrorMin(String nameString, num min, String unit) {
    return '$nameString 必须大于 $min$unit.';
  }

  @override
  String get stringInputPlaceholder => '在这里输入……';

  @override
  String get stringInputValidationErrorMin => '输入太短';

  @override
  String changesetCommentMessage(String mapFeaturesString, String stopsString) {
    return '向位于停车区域 $stopsString的$mapFeaturesString增添细节.';
  }

  @override
  String get changesetCommentConjunctionString => '和';

  @override
  String get uploadMessageSuccess => '变更成功上传。';

  @override
  String get uploadMessageServerConnectionError => '错误：无法与OSM服务器连接。';

  @override
  String get uploadMessageUnknownConnectionError => '传输过程中未知错误。';

  @override
  String get queryMessageServerUnavailableError => '服务器不可用或负荷过重，请稍后重试。';

  @override
  String get queryMessageTooManyRequestsError => '向服务器发送了过多请求。';

  @override
  String get queryMessageConnectionTimeoutError => '错误：服务器查询超时。';

  @override
  String get queryMessageReceiveTimeoutError => '错误：接收数据超时。';

  @override
  String get queryMessageUnknownServerCommunicationError => '与服务器通信过程中未知错误。';

  @override
  String get queryMessageUnknownError => '未知错误。';

  @override
  String questionnaireSummaryDedicatedMessage(String userName) {
    return '感谢$userName作答。\n请在上传前检查他们。';
  }

  @override
  String get questionnaireSummaryUndedicatedMessage => '感谢您的作答\n请在上传前检查他们。';

  @override
  String get back => '返回';

  @override
  String get next => '继续';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确认';

  @override
  String get finish => '完成';

  @override
  String get login => '登入';

  @override
  String get logout => '登出';

  @override
  String get skip => '跳过';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String days(num day) {
    String _temp0 = intl.Intl.pluralLogic(
      day,
      locale: localeName,
      other: '$day Days',
      one: '1 Day',
    );
    return '$_temp0';
  }

  @override
  String hours(num hour) {
    String _temp0 = intl.Intl.pluralLogic(
      hour,
      locale: localeName,
      other: '$hour 小时',
      one: '1 小时',
    );
    return '$_temp0';
  }

  @override
  String minutes(num minute) {
    String _temp0 = intl.Intl.pluralLogic(
      minute,
      locale: localeName,
      other: '$minute 分钟',
      one: '1 分钟',
    );
    return '$_temp0';
  }

  @override
  String seconds(num second) {
    String _temp0 = intl.Intl.pluralLogic(
      second,
      locale: localeName,
      other: '$second 秒',
      one: '1 秒',
    );
    return '$_temp0';
  }

  @override
  String get durationInputDaysLabel => '天';

  @override
  String get durationInputHoursLabel => '小时';

  @override
  String get durationInputMinutesLabel => '分钟';

  @override
  String get durationInputSecondsLabel => '秒';

  @override
  String get osmCreditsText => '数据来源 © OpenStreetMap贡献者';

  @override
  String get mapFeatureBusStop => '公交车站';

  @override
  String get mapFeatureTramStop => '电车站';

  @override
  String get mapFeatureTrainPlatform => '火车站台';

  @override
  String get mapFeaturePlatform => '站台';

  @override
  String get mapFeatureStopPole => '停车标';

  @override
  String get mapFeatureStation => '车站';

  @override
  String get mapFeatureTicketSalesPoint => '售票点';

  @override
  String get mapFeatureInformationPoint => '问询点';

  @override
  String get mapFeatureStationMap => '车站地图';

  @override
  String get mapFeatureTicketMachine => '售票机';

  @override
  String get mapFeatureParkingSpot => '停车位';

  @override
  String get mapFeatureTaxiStand => '出租车停靠点';

  @override
  String get mapFeatureToilets => '卫生间';

  @override
  String get mapFeatureLuggageLockers => '行李锁柜';

  @override
  String get mapFeatureLuggageTransport => '行李传送带';

  @override
  String get mapFeatureInformationTerminal => '信息查询终端机';

  @override
  String get mapFeatureInformationCallPoint => '信息栏';

  @override
  String get mapFeatureHelpPoint => '帮助点';

  @override
  String get mapFeatureEmergencyCallPoint => '紧急呼叫点';

  @override
  String get mapFeatureEntrance => '入口';

  @override
  String get mapFeatureFootpath => '步行道路';

  @override
  String get mapFeatureStairs => '楼梯';

  @override
  String get mapFeatureElevator => '电梯';

  @override
  String get mapFeatureEscalator => '扶梯';

  @override
  String get mapFeatureCycleBarrier => '自行车障碍';

  @override
  String get mapFeatureTramCrossing => '电车平交道口';

  @override
  String get mapFeatureRailroadCrossing => '铁路平交道口';

  @override
  String get mapFeatureCurb => 'Curb';

  @override
  String mapFeatureBusPlatformNumber(String number) {
    return '站台：$number';
  }

  @override
  String mapFeatureTrainPlatformNumber(String number) {
    return '站台：$number';
  }
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant(): super('zh_Hant');

  @override
  String get aboutTitle => '關於';

  @override
  String get aboutSlogan => '下一站：無障礙';

  @override
  String get aboutVersionLabel => '版本';

  @override
  String get aboutAuthorsLabel => '作者';

  @override
  String aboutAuthorsDescription(String appName) {
    return '$appName 貢獻者';
  }

  @override
  String get aboutPrivacyPolicyLabel => '隱私權政策';

  @override
  String get aboutIdeaLabel => '想法';

  @override
  String get aboutIdeaDescription => '肯尼茲工業大學\n電路與系統設計教職';

  @override
  String get aboutLicenseLabel => '授權條款';

  @override
  String get aboutLicensePackageLabel => '使用軟體包的授權條款';

  @override
  String get aboutSourceCodeLabel => '原始碼';

  @override
  String get helpTitle => '說明';

  @override
  String get helpOnboardingLabel => '重新觀看介紹';

  @override
  String get helpReportErrorLabel => '回報錯誤';

  @override
  String get helpImproveTranslationLabel => '改進翻譯';

  @override
  String get onboardingGreetingTitle => '嗨！';

  @override
  String get onboardingGreetingDescription => '我們很高興您來到這裡，並希望為改善大眾運輸盡一己之力。';

  @override
  String get onboardingGreetingButton => '這是運作方式';

  @override
  String get onboardingSurveyingTitle => '看一看';

  @override
  String get onboardingSurveyingDescription => '前往附近的車站調查其目前狀態。';

  @override
  String get onboardingSurveyingButton => '我做得到';

  @override
  String get onboardingAnsweringTitle => '輪到你了';

  @override
  String get onboardingAnsweringDescription => '為了蒐集資料，請在應用程式中選擇一個標記並回答顯示的問題。';

  @override
  String get onboardingAnsweringButton => '好，知道了';

  @override
  String get onboardingContributingTitle => '分享就是關懷';

  @override
  String get onboardingContributingDescription => '將您的答案上傳至 OpenStreetMap，與全世界分享。';

  @override
  String get onboardingContributingButton => '開始吧';

  @override
  String get privacyPolicyTitle => '隱私權政策';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsProfessionalQuestionsLabel => '顯示專業問題';

  @override
  String get settingsProfessionalQuestionsDescription => '出於安全原因，僅供專業人士使用';

  @override
  String get settingsThemeLabel => '應用程式的配色方案';

  @override
  String get settingsThemeDialogTitle => '選取佈景主題';

  @override
  String get settingsThemeOptionSystem => '系統設定';

  @override
  String get settingsThemeOptionLight => '淺色';

  @override
  String get settingsThemeOptionDark => '深色';

  @override
  String get logoutDialogTitle => '登出 OSM？';

  @override
  String get logoutDialogDescription => '若您登出，則無法再將變更上傳至 OpenStreetMap。';

  @override
  String get loginHint => '使用您的 OpenStreetMap 帳號登入以上傳您的變更。';

  @override
  String get numberInputPlaceholder => '在此輸入……';

  @override
  String get numberInputFallbackName => '值';

  @override
  String get numberInputValidationError => '無效號碼';

  @override
  String numberInputValidationErrorMax(String nameString, num max, String unit) {
    return '$nameString 必須少於 $max$unit。';
  }

  @override
  String numberInputValidationErrorMin(String nameString, num min, String unit) {
    return '$nameString 必須多於 $min$unit。';
  }

  @override
  String get stringInputPlaceholder => '在此輸入……';

  @override
  String get stringInputValidationErrorMin => '輸入太短';

  @override
  String changesetCommentMessage(String mapFeaturesString, String stopsString) {
    return '在停靠區域 $stopsString 中的 $mapFeaturesString 中新增了詳細資訊。';
  }

  @override
  String get changesetCommentConjunctionString => '與';

  @override
  String get uploadMessageSuccess => '變更已成功上傳。';

  @override
  String get uploadMessageServerConnectionError => '錯誤：未連線到 OSM 伺服器。';

  @override
  String get uploadMessageUnknownConnectionError => '傳輸過程中出現未知錯誤。';

  @override
  String get queryMessageServerUnavailableError => '伺服器無法使用或過載。請稍後再試。';

  @override
  String get queryMessageTooManyRequestsError => '對伺服器的請求太多。';

  @override
  String get queryMessageConnectionTimeoutError => '錯誤：伺服器查詢逾時。';

  @override
  String get queryMessageReceiveTimeoutError => '錯誤：接收資料逾時。';

  @override
  String get queryMessageUnknownServerCommunicationError => '伺服器通訊期間出現未知錯誤。';

  @override
  String get queryMessageUnknownError => '未知錯誤。';

  @override
  String questionnaireSummaryDedicatedMessage(String userName) {
    return '感謝 $userName 的回答。\n請在上傳前驗證它們。';
  }

  @override
  String get questionnaireSummaryUndedicatedMessage => '謝謝您的回答。\n請在上傳前驗證它們。';

  @override
  String get back => '上一步';

  @override
  String get next => '下一步';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '確認';

  @override
  String get finish => '結束';

  @override
  String get login => '登入';

  @override
  String get logout => '登出';

  @override
  String get skip => '略過';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String days(num day) {
    String _temp0 = intl.Intl.pluralLogic(
      day,
      locale: localeName,
      other: '$day 天',
      one: '1 天',
    );
    return '$_temp0';
  }

  @override
  String hours(num hour) {
    String _temp0 = intl.Intl.pluralLogic(
      hour,
      locale: localeName,
      other: '$hour 小時',
      one: '1 小時',
    );
    return '$_temp0';
  }

  @override
  String minutes(num minute) {
    String _temp0 = intl.Intl.pluralLogic(
      minute,
      locale: localeName,
      other: '$minute 分鐘',
      one: '1 分鐘',
    );
    return '$_temp0';
  }

  @override
  String seconds(num second) {
    String _temp0 = intl.Intl.pluralLogic(
      second,
      locale: localeName,
      other: '$second 秒',
      one: '1 秒',
    );
    return '$_temp0';
  }

  @override
  String get and => '與';

  @override
  String get more => '更多';

  @override
  String get element => '元素';

  @override
  String get durationInputDaysLabel => '天';

  @override
  String get durationInputHoursLabel => '小時';

  @override
  String get durationInputMinutesLabel => '分鐘';

  @override
  String get durationInputSecondsLabel => '秒';

  @override
  String get osmCreditsText => '資料 © OpenStreetMap 貢獻者';

  @override
  String changesetWithStopNameText(String elements, String stopArea) {
    return '在停靠區域 $stopArea 中的 $elements 新增了詳細資訊。';
  }

  @override
  String changesetWithoutStopNameText(String elements) {
    return '在停靠區域的 $elements 新增了詳細資訊。';
  }

  @override
  String get mapFeatureBusStop => '公車站';

  @override
  String get mapFeatureTramStop => '路面電車站';

  @override
  String get mapFeatureTrainPlatform => '火車月台';

  @override
  String get mapFeaturePlatform => '月台';

  @override
  String get mapFeatureStopPole => '停止桿';

  @override
  String get mapFeatureStation => '車站';

  @override
  String get mapFeatureTicketSalesPoint => '售票點';

  @override
  String get mapFeatureInformationPoint => '資訊點';

  @override
  String get mapFeatureStationMap => '站/停靠站地圖';

  @override
  String get mapFeatureTicketMachine => '售票機';

  @override
  String get mapFeatureParkingSpot => '停車位';

  @override
  String get mapFeatureTaxiStand => '計程車站';

  @override
  String get mapFeatureToilets => '廁所';

  @override
  String get mapFeatureLuggageLockers => '行李置物櫃';

  @override
  String get mapFeatureLuggageTransport => '行李運輸';

  @override
  String get mapFeatureInformationTerminal => '資訊終端機';

  @override
  String get mapFeatureInformationCallPoint => '資訊欄位';

  @override
  String get mapFeatureHelpPoint => '協助點';

  @override
  String get mapFeatureEmergencyCallPoint => '緊急呼叫點';

  @override
  String get mapFeatureEntrance => '入口';

  @override
  String get mapFeatureFootpath => '人行道';

  @override
  String get mapFeatureCyclePath => '腳踏車道';

  @override
  String get mapFeatureFootAndCyclePath => '人行與腳踏車道';

  @override
  String get mapFeatureStairs => '樓梯';

  @override
  String get mapFeatureElevator => '電梯';

  @override
  String get mapFeatureEscalator => '電扶梯';

  @override
  String get mapFeatureCycleBarrier => '腳踏車障礙物';

  @override
  String get mapFeatureCrossing => '交叉路口';

  @override
  String get mapFeatureTramCrossing => '路面電車路口';

  @override
  String get mapFeatureRailroadCrossing => '平交道';

  @override
  String get mapFeatureFootwayCrossing => '行人穿越道';

  @override
  String get mapFeatureCyclewayCrossing => '腳踏車穿越道';

  @override
  String get mapFeatureCurb => '路緣';

  @override
  String get mapFeaturePedestrianLights => '行人燈號';

  @override
  String mapFeatureBusPlatformNumber(String number) {
    return '月台：$number';
  }

  @override
  String mapFeatureTrainPlatformNumber(String number) {
    return '月台：$number';
  }
}
