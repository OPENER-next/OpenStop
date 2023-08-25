import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:nock/nock.dart';
import 'package:open_stop/api/app_worker/app_worker_interface.dart';
import 'package:open_stop/api/preferences_service.dart';
import 'package:open_stop/main.dart';
import 'package:open_stop/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:open_stop/models/question_catalog/question_catalog_reader.dart';

const overpassReply = {
  'version': 0.6,
  'generator': '',
  'osm3s': {
    'timestamp_osm_base': '',
    'copyright': ''
  },
  'elements': []
};

const osmPermissionReply = '{"version":"0.6","generator":"OpenStreetMap server","permissions":[]}';


void main() {
  setUpAll((){
    nock.defaultBase = '';
    nock.init();

    // required to prevent: https://stackoverflow.com/questions/73591769
    FlutterError.demangleStackTrace = (stack) {
      // Trace and Chain are classes in package:stack_trace
      if (stack is Trace) {
        return stack.vmTrace;
      }
      if (stack is Chain) {
        return stack.toTrace().vmTrace;
      }
      return stack;
    };
  });


  setUp(nock.cleanAll);


  testWidgets('Basic app start test', (WidgetTester tester) async {
    // mock preferences
    SharedPreferences.setMockInitialValues({
      'hasSeenOnboarding': false
    });
    // mock overpass requests
    nock.get('https://overpass-api.de/api/interpreter')
      ..query({'data': anything, 'bbox': anything})
      ..reply(200, overpassReply, headers: { 'Content-Type': 'application/json' })
      ..persist();
    nock.get('https://overpass.kumi.systems/api/interpreter')
      ..query({'data': anything, 'bbox': anything})
      ..reply(200, overpassReply, headers: { 'Content-Type': 'application/json' })
      ..persist();
    // mock osm api requests
    nock.get('https://master.apis.dev.openstreetmap.org/api/0.6/permissions')
      ..reply(200, osmPermissionReply, headers: { 'Content-Type': 'application/json' })
      ..persist();

    // set screen size (mainly for emulator testing)
    await tester.binding.setSurfaceSize(const Size(1080, 1920));

    await tester.runAsync(() async {
      // main function init
      final futures = await Future.wait([
        AppWorkerInterface.spawn(),
        SharedPreferences.getInstance(),
      ]);

      GetIt.I.registerSingleton<AppWorkerInterface>(futures[0] as AppWorkerInterface);
      GetIt.I.registerSingleton<PreferencesService>(
        PreferencesService(preferences: futures[1] as SharedPreferences),
      );

      const mainCatalogDirectory = 'assets/question_catalog';

      final questionCatalogReader = QuestionCatalogReader(
        assetPaths: [mainCatalogDirectory],
      );

      questionCatalogReader.questionCatalog.listen((questionCatalogChange) {
        GetIt.I.get<AppWorkerInterface>().updateQuestionCatalog(questionCatalogChange);
      });

      final assets = await Future.wait([
        rootBundle.load('assets/datasets/map_feature_collection.json')
      ]);

      GetIt.I.get<AppWorkerInterface>().passAssets(assets);
    });

    // build app and trigger first frame
    await tester.pumpWidget(const MyApp());

    // skip through the onboarding screen
    final nextButton = find.byType(OutlinedButton, skipOffstage: true);
    await tester.tap(nextButton);
    await tester.pumpAndSettle();
    await tester.tap(nextButton);
    await tester.pumpAndSettle();
    await tester.tap(nextButton);
    await tester.pumpAndSettle();
    await tester.tap(nextButton);
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
