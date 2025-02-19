import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_be.dart';
import 'app_localizations_cs.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_nb.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('be'),
    Locale('cs'),
    Locale('de'),
    Locale('es'),
    Locale('fa'),
    Locale('fr'),
    Locale('hr'),
    Locale('it'),
    Locale('nb'),
    Locale('pt', 'BR'),
    Locale('pt'),
    Locale('ru'),
    Locale('sv'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    Locale('zh')
  ];

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutSlogan.
  ///
  /// In en, this message translates to:
  /// **'Next stop: Accessibility'**
  String get aboutSlogan;

  /// No description provided for @aboutVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersionLabel;

  /// No description provided for @aboutAuthorsLabel.
  ///
  /// In en, this message translates to:
  /// **'Authors'**
  String get aboutAuthorsLabel;

  /// No description provided for @aboutAuthorsDescription.
  ///
  /// In en, this message translates to:
  /// **'{appName} contributors'**
  String aboutAuthorsDescription(String appName);

  /// No description provided for @aboutPrivacyPolicyLabel.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get aboutPrivacyPolicyLabel;

  /// No description provided for @aboutIdeaLabel.
  ///
  /// In en, this message translates to:
  /// **'Idea'**
  String get aboutIdeaLabel;

  /// No description provided for @aboutIdeaDescription.
  ///
  /// In en, this message translates to:
  /// **'Chemnitz University of Technology\nProfessorship Circuit and System Design'**
  String get aboutIdeaDescription;

  /// No description provided for @aboutLicenseLabel.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get aboutLicenseLabel;

  /// No description provided for @aboutLicensePackageLabel.
  ///
  /// In en, this message translates to:
  /// **'Licenses of used packages'**
  String get aboutLicensePackageLabel;

  /// No description provided for @aboutSourceCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get aboutSourceCodeLabel;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpTitle;

  /// No description provided for @helpOnboardingLabel.
  ///
  /// In en, this message translates to:
  /// **'Watch the introduction again'**
  String get helpOnboardingLabel;

  /// No description provided for @helpReportErrorLabel.
  ///
  /// In en, this message translates to:
  /// **'Report an error'**
  String get helpReportErrorLabel;

  /// No description provided for @helpImproveTranslationLabel.
  ///
  /// In en, this message translates to:
  /// **'Improve the translation'**
  String get helpImproveTranslationLabel;

  /// No description provided for @onboardingGreetingTitle.
  ///
  /// In en, this message translates to:
  /// **'Hey!'**
  String get onboardingGreetingTitle;

  /// No description provided for @onboardingGreetingDescription.
  ///
  /// In en, this message translates to:
  /// **'We\'re glad you\'re here and want to do your part to improve public transport.'**
  String get onboardingGreetingDescription;

  /// No description provided for @onboardingGreetingButton.
  ///
  /// In en, this message translates to:
  /// **'Here\'s how it works'**
  String get onboardingGreetingButton;

  /// No description provided for @onboardingSurveyingTitle.
  ///
  /// In en, this message translates to:
  /// **'Take a look'**
  String get onboardingSurveyingTitle;

  /// No description provided for @onboardingSurveyingDescription.
  ///
  /// In en, this message translates to:
  /// **'Go to a nearby stop to survey its current state.'**
  String get onboardingSurveyingDescription;

  /// No description provided for @onboardingSurveyingButton.
  ///
  /// In en, this message translates to:
  /// **'I\'ll do it'**
  String get onboardingSurveyingButton;

  /// No description provided for @onboardingAnsweringTitle.
  ///
  /// In en, this message translates to:
  /// **'Now it\'s your turn'**
  String get onboardingAnsweringTitle;

  /// No description provided for @onboardingAnsweringDescription.
  ///
  /// In en, this message translates to:
  /// **'In order to collect data select a marker in the app and answer the displayed questions.'**
  String get onboardingAnsweringDescription;

  /// No description provided for @onboardingAnsweringButton.
  ///
  /// In en, this message translates to:
  /// **'Okay, got it'**
  String get onboardingAnsweringButton;

  /// No description provided for @onboardingContributingTitle.
  ///
  /// In en, this message translates to:
  /// **'Sharing is caring'**
  String get onboardingContributingTitle;

  /// No description provided for @onboardingContributingDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload your answers to OpenStreetMap to share them with the whole world.'**
  String get onboardingContributingDescription;

  /// No description provided for @onboardingContributingButton.
  ///
  /// In en, this message translates to:
  /// **'Here we go'**
  String get onboardingContributingButton;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsProfessionalQuestionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Display Professional Questions'**
  String get settingsProfessionalQuestionsLabel;

  /// No description provided for @settingsProfessionalQuestionsDescription.
  ///
  /// In en, this message translates to:
  /// **'For safety reasons only intended for professionals'**
  String get settingsProfessionalQuestionsDescription;

  /// No description provided for @settingsThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'Color Scheme of the App'**
  String get settingsThemeLabel;

  /// No description provided for @settingsThemeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Select theme'**
  String get settingsThemeDialogTitle;

  /// No description provided for @settingsThemeOptionSystem.
  ///
  /// In en, this message translates to:
  /// **'System Setting'**
  String get settingsThemeOptionSystem;

  /// No description provided for @settingsThemeOptionLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeOptionLight;

  /// No description provided for @settingsThemeOptionDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeOptionDark;

  /// No description provided for @logoutDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out of OSM?'**
  String get logoutDialogTitle;

  /// No description provided for @logoutDialogDescription.
  ///
  /// In en, this message translates to:
  /// **'If you log out, you can no longer upload changes to OpenStreetMap.'**
  String get logoutDialogDescription;

  /// No description provided for @loginHint.
  ///
  /// In en, this message translates to:
  /// **'Log in with your OpenStreetMap account to upload your changes.'**
  String get loginHint;

  /// No description provided for @numberInputPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter here…'**
  String get numberInputPlaceholder;

  /// Fallback value for nameString in numberInputValidationErrorMax
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get numberInputFallbackName;

  /// No description provided for @numberInputValidationError.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get numberInputValidationError;

  /// No description provided for @numberInputValidationErrorMax.
  ///
  /// In en, this message translates to:
  /// **'{nameString} must be less than {max}{unit}.'**
  String numberInputValidationErrorMax(String nameString, num max, String unit);

  /// No description provided for @numberInputValidationErrorMin.
  ///
  /// In en, this message translates to:
  /// **'{nameString} must be greater than {min}{unit}.'**
  String numberInputValidationErrorMin(String nameString, num min, String unit);

  /// No description provided for @stringInputPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter here…'**
  String get stringInputPlaceholder;

  /// No description provided for @stringInputValidationErrorMin.
  ///
  /// In en, this message translates to:
  /// **'Input too short'**
  String get stringInputValidationErrorMin;

  /// No description provided for @changesetCommentMessage.
  ///
  /// In en, this message translates to:
  /// **'Added details to {mapFeaturesString} in stop area {stopsString}.'**
  String changesetCommentMessage(String mapFeaturesString, String stopsString);

  /// No description provided for @changesetCommentConjunctionString.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get changesetCommentConjunctionString;

  /// No description provided for @uploadMessageSuccess.
  ///
  /// In en, this message translates to:
  /// **'Changes successfully uploaded.'**
  String get uploadMessageSuccess;

  /// No description provided for @uploadMessageServerConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Error: No connection to the OSM server.'**
  String get uploadMessageServerConnectionError;

  /// No description provided for @uploadMessageUnknownConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error during transmission.'**
  String get uploadMessageUnknownConnectionError;

  /// No description provided for @queryMessageServerUnavailableError.
  ///
  /// In en, this message translates to:
  /// **'Server unavailable or overloaded. Try again later.'**
  String get queryMessageServerUnavailableError;

  /// No description provided for @queryMessageTooManyRequestsError.
  ///
  /// In en, this message translates to:
  /// **'Too many requests to the server.'**
  String get queryMessageTooManyRequestsError;

  /// No description provided for @queryMessageConnectionTimeoutError.
  ///
  /// In en, this message translates to:
  /// **'Error: Server query timed out.'**
  String get queryMessageConnectionTimeoutError;

  /// No description provided for @queryMessageReceiveTimeoutError.
  ///
  /// In en, this message translates to:
  /// **'Error: Receiving data timed out.'**
  String get queryMessageReceiveTimeoutError;

  /// No description provided for @queryMessageUnknownServerCommunicationError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error during server communication.'**
  String get queryMessageUnknownServerCommunicationError;

  /// No description provided for @queryMessageUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error.'**
  String get queryMessageUnknownError;

  /// No description provided for @questionnaireSummaryDedicatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Thank you {userName} for your answers.\nPlease verify them before uploading.'**
  String questionnaireSummaryDedicatedMessage(String userName);

  /// No description provided for @questionnaireSummaryUndedicatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your answers.\nPlease verify them before uploading.'**
  String get questionnaireSummaryUndedicatedMessage;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'{day, plural, =1 {1 day} other {{day} days}}'**
  String days(num day);

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'{hour, plural, =1 {1 hour} other {{hour} hours}}'**
  String hours(num hour);

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'{minute, plural, =1 {1 minute} other {{minute} minutes}}'**
  String minutes(num minute);

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'{second, plural, =1 {1 second} other {{second} seconds}}'**
  String seconds(num second);

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'more'**
  String get more;

  /// No description provided for @element.
  ///
  /// In en, this message translates to:
  /// **'element'**
  String get element;

  /// No description provided for @durationInputDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get durationInputDaysLabel;

  /// No description provided for @durationInputHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get durationInputHoursLabel;

  /// No description provided for @durationInputMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get durationInputMinutesLabel;

  /// No description provided for @durationInputSecondsLabel.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get durationInputSecondsLabel;

  /// No description provided for @osmCreditsText.
  ///
  /// In en, this message translates to:
  /// **'Data © OpenStreetMap contributors'**
  String get osmCreditsText;

  /// No description provided for @changesetWithStopNameText.
  ///
  /// In en, this message translates to:
  /// **'Added details to {elements} in the stop area {stopArea}.'**
  String changesetWithStopNameText(String elements, String stopArea);

  /// No description provided for @changesetWithoutStopNameText.
  ///
  /// In en, this message translates to:
  /// **'Added details to {elements} in the stop area.'**
  String changesetWithoutStopNameText(String elements);

  /// No description provided for @mapFeatureBusStop.
  ///
  /// In en, this message translates to:
  /// **'Bus stop'**
  String get mapFeatureBusStop;

  /// No description provided for @mapFeatureTramStop.
  ///
  /// In en, this message translates to:
  /// **'Tram stop'**
  String get mapFeatureTramStop;

  /// No description provided for @mapFeatureTrainPlatform.
  ///
  /// In en, this message translates to:
  /// **'Train platform'**
  String get mapFeatureTrainPlatform;

  /// No description provided for @mapFeaturePlatform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get mapFeaturePlatform;

  /// No description provided for @mapFeatureStopPole.
  ///
  /// In en, this message translates to:
  /// **'Stop pole'**
  String get mapFeatureStopPole;

  /// No description provided for @mapFeatureStation.
  ///
  /// In en, this message translates to:
  /// **'Station'**
  String get mapFeatureStation;

  /// No description provided for @mapFeatureTicketSalesPoint.
  ///
  /// In en, this message translates to:
  /// **'Ticket sales point'**
  String get mapFeatureTicketSalesPoint;

  /// No description provided for @mapFeatureInformationPoint.
  ///
  /// In en, this message translates to:
  /// **'Information point'**
  String get mapFeatureInformationPoint;

  /// No description provided for @mapFeatureStationMap.
  ///
  /// In en, this message translates to:
  /// **'Station/Stop map'**
  String get mapFeatureStationMap;

  /// No description provided for @mapFeatureTicketMachine.
  ///
  /// In en, this message translates to:
  /// **'Ticket machine'**
  String get mapFeatureTicketMachine;

  /// No description provided for @mapFeatureParkingSpot.
  ///
  /// In en, this message translates to:
  /// **'Parking spot'**
  String get mapFeatureParkingSpot;

  /// No description provided for @mapFeatureTaxiStand.
  ///
  /// In en, this message translates to:
  /// **'Taxi stand'**
  String get mapFeatureTaxiStand;

  /// No description provided for @mapFeatureToilets.
  ///
  /// In en, this message translates to:
  /// **'Toilets'**
  String get mapFeatureToilets;

  /// No description provided for @mapFeatureLuggageLockers.
  ///
  /// In en, this message translates to:
  /// **'Luggage lockers'**
  String get mapFeatureLuggageLockers;

  /// No description provided for @mapFeatureLuggageTransport.
  ///
  /// In en, this message translates to:
  /// **'Luggage transport'**
  String get mapFeatureLuggageTransport;

  /// No description provided for @mapFeatureInformationTerminal.
  ///
  /// In en, this message translates to:
  /// **'Information terminal'**
  String get mapFeatureInformationTerminal;

  /// No description provided for @mapFeatureInformationCallPoint.
  ///
  /// In en, this message translates to:
  /// **'Information column'**
  String get mapFeatureInformationCallPoint;

  /// No description provided for @mapFeatureHelpPoint.
  ///
  /// In en, this message translates to:
  /// **'Help point'**
  String get mapFeatureHelpPoint;

  /// No description provided for @mapFeatureEmergencyCallPoint.
  ///
  /// In en, this message translates to:
  /// **'Emergency call point'**
  String get mapFeatureEmergencyCallPoint;

  /// No description provided for @mapFeatureEntrance.
  ///
  /// In en, this message translates to:
  /// **'Entrance'**
  String get mapFeatureEntrance;

  /// No description provided for @mapFeatureFootpath.
  ///
  /// In en, this message translates to:
  /// **'Footpath'**
  String get mapFeatureFootpath;

  /// No description provided for @mapFeatureCyclePath.
  ///
  /// In en, this message translates to:
  /// **'Cycle path'**
  String get mapFeatureCyclePath;

  /// No description provided for @mapFeatureFootAndCyclePath.
  ///
  /// In en, this message translates to:
  /// **'Foot & cycle path'**
  String get mapFeatureFootAndCyclePath;

  /// No description provided for @mapFeatureStairs.
  ///
  /// In en, this message translates to:
  /// **'Stairs'**
  String get mapFeatureStairs;

  /// No description provided for @mapFeatureElevator.
  ///
  /// In en, this message translates to:
  /// **'Elevator'**
  String get mapFeatureElevator;

  /// No description provided for @mapFeatureEscalator.
  ///
  /// In en, this message translates to:
  /// **'Escalator'**
  String get mapFeatureEscalator;

  /// No description provided for @mapFeatureCycleBarrier.
  ///
  /// In en, this message translates to:
  /// **'Cycle barrier'**
  String get mapFeatureCycleBarrier;

  /// No description provided for @mapFeatureCrossing.
  ///
  /// In en, this message translates to:
  /// **'Crossing'**
  String get mapFeatureCrossing;

  /// No description provided for @mapFeatureTramCrossing.
  ///
  /// In en, this message translates to:
  /// **'Tram crossing'**
  String get mapFeatureTramCrossing;

  /// No description provided for @mapFeatureRailroadCrossing.
  ///
  /// In en, this message translates to:
  /// **'Railroad crossing'**
  String get mapFeatureRailroadCrossing;

  /// No description provided for @mapFeatureFootwayCrossing.
  ///
  /// In en, this message translates to:
  /// **'Footway crossing'**
  String get mapFeatureFootwayCrossing;

  /// No description provided for @mapFeatureCyclewayCrossing.
  ///
  /// In en, this message translates to:
  /// **'Cycleway crossing'**
  String get mapFeatureCyclewayCrossing;

  /// No description provided for @mapFeatureCurb.
  ///
  /// In en, this message translates to:
  /// **'Curb'**
  String get mapFeatureCurb;

  /// No description provided for @mapFeaturePedestrianLights.
  ///
  /// In en, this message translates to:
  /// **'Pedestrian lights'**
  String get mapFeaturePedestrianLights;

  /// No description provided for @mapFeatureBusPlatformNumber.
  ///
  /// In en, this message translates to:
  /// **'Platform: {number}'**
  String mapFeatureBusPlatformNumber(String number);

  /// No description provided for @mapFeatureTrainPlatformNumber.
  ///
  /// In en, this message translates to:
  /// **'Platform: {number}'**
  String mapFeatureTrainPlatformNumber(String number);

  /// No description provided for @semanticsLoginHint.
  ///
  /// In en, this message translates to:
  /// **'Log in with your OpenStreetMap account to upload your changes.'**
  String get semanticsLoginHint;

  /// No description provided for @semanticsFlutterMap.
  ///
  /// In en, this message translates to:
  /// **'Map screen'**
  String get semanticsFlutterMap;

  /// No description provided for @semanticsReturnToMap.
  ///
  /// In en, this message translates to:
  /// **'Close questionnaire and return to map'**
  String get semanticsReturnToMap;

  /// No description provided for @semanticsDotsIndicator.
  ///
  /// In en, this message translates to:
  /// **'Page {number}'**
  String semanticsDotsIndicator(num number);

  /// No description provided for @semanticsPageIndicators.
  ///
  /// In en, this message translates to:
  /// **'There are {number} introduction pages, select the one you would like to hear.'**
  String semanticsPageIndicators(num number);

  /// No description provided for @semanticsIntroductionPage.
  ///
  /// In en, this message translates to:
  /// **'Introduction page {number} of {count}'**
  String semanticsIntroductionPage(num number, num count);

  /// No description provided for @semanticsSlogan.
  ///
  /// In en, this message translates to:
  /// **'Slogan'**
  String get semanticsSlogan;

  /// No description provided for @semanticsMFundImage.
  ///
  /// In en, this message translates to:
  /// **'Funded by mFUND'**
  String get semanticsMFundImage;

  /// No description provided for @semanticsFederalMinistryImage.
  ///
  /// In en, this message translates to:
  /// **'Funded by Federal Ministry of Transport and Digital Infrastructure'**
  String get semanticsFederalMinistryImage;

  /// No description provided for @semanticsSettingsDialogBox.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred app theme'**
  String get semanticsSettingsDialogBox;

  /// No description provided for @semanticsNavigationMenu.
  ///
  /// In en, this message translates to:
  /// **'Navigation menu'**
  String get semanticsNavigationMenu;

  /// No description provided for @semanticsResetRotationButton.
  ///
  /// In en, this message translates to:
  /// **'Reset map rotation to north.'**
  String get semanticsResetRotationButton;

  /// No description provided for @semanticsCurrentLocationButton.
  ///
  /// In en, this message translates to:
  /// **'Set map to current location.'**
  String get semanticsCurrentLocationButton;

  /// No description provided for @semanticsZoomInButton.
  ///
  /// In en, this message translates to:
  /// **'Zoom in map'**
  String get semanticsZoomInButton;

  /// No description provided for @semanticsZoomOutButton.
  ///
  /// In en, this message translates to:
  /// **'Zoom out map'**
  String get semanticsZoomOutButton;

  /// No description provided for @semanticsQuestionSentence.
  ///
  /// In en, this message translates to:
  /// **'The question is: '**
  String get semanticsQuestionSentence;

  /// No description provided for @semanticsUploadQuestionsButton.
  ///
  /// In en, this message translates to:
  /// **'Upload answers'**
  String get semanticsUploadQuestionsButton;

  /// No description provided for @semanticsBackQuestionButton.
  ///
  /// In en, this message translates to:
  /// **'Return to previous question.'**
  String get semanticsBackQuestionButton;

  /// No description provided for @semanticsNextQuestionButton.
  ///
  /// In en, this message translates to:
  /// **'Next question'**
  String get semanticsNextQuestionButton;

  /// No description provided for @semanticsSkipQuestionButton.
  ///
  /// In en, this message translates to:
  /// **'Skip question'**
  String get semanticsSkipQuestionButton;

  /// No description provided for @semanticsFinishQuestionnaireButton.
  ///
  /// In en, this message translates to:
  /// **'Finish questionnaire'**
  String get semanticsFinishQuestionnaireButton;

  /// No description provided for @semanticsSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get semanticsSummary;

  /// No description provided for @semanticsCloseNavigationMenuButton.
  ///
  /// In en, this message translates to:
  /// **'Close navigation menu.'**
  String get semanticsCloseNavigationMenuButton;

  /// No description provided for @semanticsCloseQuestionnaireAnnounce.
  ///
  /// In en, this message translates to:
  /// **'Questionnaire is closed'**
  String get semanticsCloseQuestionnaireAnnounce;

  /// No description provided for @semanticsOpenQuestionnaireAnnounce.
  ///
  /// In en, this message translates to:
  /// **'Questionnaire is open'**
  String get semanticsOpenQuestionnaireAnnounce;

  /// No description provided for @semanticsUser.
  ///
  /// In en, this message translates to:
  /// **'User {username} activate to open browser profile'**
  String semanticsUser(Object username);

  /// No description provided for @semanticsLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out from your user account'**
  String get semanticsLogout;

  /// No description provided for @semanticsClearField.
  ///
  /// In en, this message translates to:
  /// **'Clear field'**
  String get semanticsClearField;

  /// No description provided for @semanticsDurationAnswerReset.
  ///
  /// In en, this message translates to:
  /// **'Reset duration'**
  String get semanticsDurationAnswerReset;

  /// No description provided for @semanticsDurationAnswerStartStopwatch.
  ///
  /// In en, this message translates to:
  /// **'Start stopwatch'**
  String get semanticsDurationAnswerStartStopwatch;

  /// No description provided for @semanticsDurationAnswerStopStopwatch.
  ///
  /// In en, this message translates to:
  /// **'Stop stopwatch'**
  String get semanticsDurationAnswerStopStopwatch;

  /// No description provided for @semanticsReviewQuestion.
  ///
  /// In en, this message translates to:
  /// **'Activate to return to question'**
  String get semanticsReviewQuestion;

  /// No description provided for @semanticsNextStepOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get semanticsNextStepOnboarding;

  /// No description provided for @semanticsFinishOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Finish introduction'**
  String get semanticsFinishOnboarding;

  /// No description provided for @semanticsCredits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get semanticsCredits;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['be', 'cs', 'de', 'en', 'es', 'fa', 'fr', 'hr', 'it', 'nb', 'pt', 'ru', 'sv', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {

  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh': {
  switch (locale.scriptCode) {
    case 'Hans': return AppLocalizationsZhHans();
case 'Hant': return AppLocalizationsZhHant();
   }
  break;
   }
  }

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt': {
  switch (locale.countryCode) {
    case 'BR': return AppLocalizationsPtBr();
   }
  break;
   }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'be': return AppLocalizationsBe();
    case 'cs': return AppLocalizationsCs();
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fa': return AppLocalizationsFa();
    case 'fr': return AppLocalizationsFr();
    case 'hr': return AppLocalizationsHr();
    case 'it': return AppLocalizationsIt();
    case 'nb': return AppLocalizationsNb();
    case 'pt': return AppLocalizationsPt();
    case 'ru': return AppLocalizationsRu();
    case 'sv': return AppLocalizationsSv();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
