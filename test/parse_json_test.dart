import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:open_stop/models/question_catalog/question_catalog.dart';
import 'package:open_stop/models/question_catalog/question_catalog_reader.dart';

void main() async {
  // required to use rootBundle
  // https://stackoverflow.com/questions/49480080/flutter-load-assets-for-tests
  TestWidgetsFlutterBinding.ensureInitialized();

  late QuestionCatalog questionCatalog;

  setUpAll(() async {
    final mainCatalogDirectory = 'assets/question_catalog';
    final questionCatalogReader = QuestionCatalogReader(
    assetPaths: [ mainCatalogDirectory,],
    );

    final completer = Completer<QuestionCatalogChange>();

    questionCatalogReader.questionCatalog.listen((questionCatalogChange) {
      completer.complete(questionCatalogChange);
    });

    final questionCatalogChange = await completer.future;
    questionCatalog = questionCatalogChange.catalog;
  });

  test('test if the question_catalog.json can be parsed successfully to its corresponding models', () {
    expect(
      questionCatalog,
      isInstanceOf<QuestionCatalog>()
    );
  });
}
