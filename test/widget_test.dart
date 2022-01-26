import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:opener_next/main.dart';

void main() {
  testWidgets('Basic app start test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'hasSeenOnboarding': false
    });
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
      sharedPreferences: await SharedPreferences.getInstance()
    ));

    final startButton = find.byType(ElevatedButton);

    await tester.dragUntilVisible(
      startButton,
      find.byType(PageView),
      const Offset(-250, 0),
    );

    expect(startButton, findsOneWidget);
  });
}
