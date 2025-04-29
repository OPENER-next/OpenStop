import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/api/app_worker/app_worker_interface.dart';
import '/api/preferences_service.dart';
import '/commons/app_config.dart';
import '/commons/routes.dart';
import '/commons/themes.dart';
import '/l10n/app_localizations.g.dart';
import '/models/question_catalog/question_catalog_reader.dart';
import 'widgets/locale_change_notifier.dart';

Future <void> main() async {
  // this is required to run flutter dependent code before runApp is called
  // in this case SharedPreferences requires this
  WidgetsFlutterBinding.ensureInitialized();

  late final AppWorkerInterface appWorker;
  late final SharedPreferences sharedPreferences;

  await Future.wait([
    AppWorkerInterface.spawn().then((v) => appWorker = v),
    SharedPreferences.getInstance().then((v) => sharedPreferences = v),
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge),
  ]);

  GetIt.I.registerSingleton<AppWorkerInterface>(appWorker);
  GetIt.I.registerSingleton<PreferencesService>(
    PreferencesService(preferences: sharedPreferences),
  );

  const mainCatalogDirectory = 'assets/question_catalog';
  const professionalCatalogDirectory = 'assets/advanced_question_catalog';

  final questionCatalogReader = QuestionCatalogReader(
    assetPaths: [
      mainCatalogDirectory,
      if (GetIt.I.get<PreferencesService>().isProfessional) professionalCatalogDirectory,
    ],
  );

  questionCatalogReader.questionCatalog.listen((questionCatalogChange) {
    GetIt.I.get<AppWorkerInterface>().updateQuestionCatalog(questionCatalogChange);
  });

  // This will clear all pending questionnaires
  reaction((p0) => GetIt.I.get<PreferencesService>().isProfessional, (value) async {
    questionCatalogReader.assetPaths = [
      mainCatalogDirectory,
      if (value) professionalCatalogDirectory
    ];
  }, fireImmediately: true);

  runApp(const MyApp());
}

class MyApp extends StatelessObserverWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final preferenceService = GetIt.I.get<PreferencesService>();
    final themeMode = preferenceService.themeMode;
    final hasSeenOnboarding = preferenceService.hasSeenOnboarding;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: kAppName,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // used instead of home: because otherwise no pop page transition to the first screen will be applied
      onGenerateRoute: (settings) => hasSeenOnboarding ? Routes.home : Routes.onboarding,
      theme: lightTheme,
      builder: (context, child) => LocaleChangeNotifier(
        onChange: GetIt.I.get<AppWorkerInterface>().updateLocales,
        child: child,
      ),
      darkTheme: darkTheme,
      highContrastTheme: highContrastLightTheme,
      highContrastDarkTheme: highContrastDarkTheme,
      themeMode: themeMode,
    );
  }
}
