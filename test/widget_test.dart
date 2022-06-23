import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nock/nock.dart';
import 'package:open_stop/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_stop/main.dart';

const overpassReply = {
  'version': 0.6,
  'generator': '',
  'osm3s': {
    'timestamp_osm_base': '',
    'copyright': ''
  },
  'elements': []
};

const osmPermissionReply =
  '<?xml version="1.0" encoding="UTF-8"?>'
  '<osm version="0.6" generator="OpenStreetMap server">'
    '<permissions>'
    '</permissions>'
  '</osm>';

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
      ..reply(200, osmPermissionReply)
      ..persist();

    // set screen size (mainly for emulator testing)
    await tester.binding.setSurfaceSize(const Size(1080, 1920));

    // build app and trigger first frame
    await tester.pumpWidget(MyApp(
      sharedPreferences: await SharedPreferences.getInstance()
    ));
    // skip through the onboarding screen
    final nextButton = find.byType(OutlinedButton, skipOffstage: true);
    await tester.tap(nextButton);
    await tester.pumpAndSettle();
    await tester.tap(nextButton);
    await tester.pumpAndSettle();
    await tester.tap(nextButton);
    await tester.pumpAndSettle();
    await tester.tap(nextButton);
    await tester.pump();

    await tester.pump();
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
