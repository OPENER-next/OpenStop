import 'package:flutter_test/flutter_test.dart';
import 'package:open_stop/models/question_catalog/question_catalog.dart';
import 'package:open_stop/models/question_catalog/question_catalog_reader.dart';

void main() async {
  // required to use rootBundle
  // https://stackoverflow.com/questions/49480080/flutter-load-assets-for-tests
  TestWidgetsFlutterBinding.ensureInitialized();

  late final QuestionCatalog questionJson;

  setUpAll(() async {
    final QuestionCatalogReader questionCatalogReader = QuestionCatalogReader();
    questionJson = await questionCatalogReader.read();
  });

  test('test if the question_catalog.json can be parsed successfully to its corresponding models', () {
    expect(
      questionJson,
      isInstanceOf<QuestionCatalog>()
    );
  });
}
