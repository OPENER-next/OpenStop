

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opener_next/models/question_catalog.dart';

void main() async {
  // required to use rootBundle
  // https://stackoverflow.com/questions/49480080/flutter-load-assets-for-tests
  TestWidgetsFlutterBinding.ensureInitialized();

  late final List<Map<String, dynamic>> questionJson;

  setUpAll(() async {
    final questionJsonData = await rootBundle.loadString('assets/datasets/question_catalog.json');
    questionJson = jsonDecode(questionJsonData).cast<Map<String, dynamic>>();
  });

  test('test if the question_catalog.json can be parsed successfully to its corresponding models', () {
    expect(
      QuestionCatalog.fromJson(questionJson),
      isInstanceOf<QuestionCatalog>()
    );
  });
}
