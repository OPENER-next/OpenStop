import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nock/nock.dart';
import 'package:open_stop/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_stop/main.dart';

const overpassReply = '''
  {
    "version": 0.6,
    "generator": "",
    "osm3s": {
      "timestamp_osm_base": "",
      "copyright": ""
    },
    "elements": []
  }
''';

void main() {
  setUpAll((){
    nock.defaultBase = '';
    nock.init();
  });


  setUp(nock.cleanAll);


  testWidgets('Basic app start test', (WidgetTester tester) async {
    // mock preferences
    SharedPreferences.setMockInitialValues({
      'hasSeenOnboarding': false
    });
    // mock overpass requests
    nock.get(startsWith('https://overpass-api.de/api/interpreter'))
      .reply(200, overpassReply, headers: {
        'Content-Type': 'application/json'
      });

    nock.get(startsWith('https://overpass.kumi.systems/api/interpreter'))
      .reply(200, overpassReply, headers: {
        'Content-Type': 'application/json'
      });

    // build app and trigger first frame
    await tester.pumpWidget(MyApp(
      sharedPreferences: await SharedPreferences.getInstance()
    ));

    // skip through the onboarding screen
    final nextButton = find.byType(OutlinedButton);
    while(findsOneWidget.matches(nextButton, {})) {
      await tester.tap(nextButton);
      await tester.pumpAndSettle();
    }

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
