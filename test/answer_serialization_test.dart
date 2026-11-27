import 'package:flutter_test/flutter_test.dart';
import 'package:open_stop/models/answer.dart';
import 'package:open_stop/models/answer_serialization.dart';
import 'package:open_stop/models/question_catalog/answer_constructor.dart';
import 'package:open_stop/models/question_catalog/answer_definition.dart';
import 'package:open_stop/models/question_catalog/question_catalog.dart';
import 'package:open_stop/models/question_catalog/question_catalog_reader.dart';
import 'package:open_stop/models/question_catalog/question_definition.dart';

void main() {
  group('answer serialization', () {
    const constructor = AnswerConstructor({'a': [r'$input']});

    test('string and number answers round trip', () {
      const stringDef = StringAnswerDefinition(input: StringInputDefinition(), constructor: constructor);
      final string = answerFromJson(
        stringDef,
        answerToJson(const StringAnswer(definition: stringDef, value: 'abc')),
      );
      expect(string, isA<StringAnswer>().having((a) => a.value, 'value', 'abc'));

      const numberDef = NumberAnswerDefinition(input: NumberInputDefinition(), constructor: constructor);
      final number = answerFromJson(
        numberDef,
        answerToJson(const NumberAnswer(definition: numberDef, value: '1.5')),
      );
      expect(number, isA<NumberAnswer>().having((a) => a.value, 'value', '1.5'));
    });

    test('list, multi list, bool and duration answers round trip', () {
      final listDef = ListAnswerDefinition(
        input: [
          const ListInputDefinition(osmTags: {'a': '1'}, name: 'one'),
          const ListInputDefinition(osmTags: {'a': '2'}, name: 'two'),
        ],
        constructor: constructor,
      );
      expect(
        answerFromJson(listDef, answerToJson(ListAnswer(definition: listDef, value: 1))),
        isA<ListAnswer>().having((a) => a.value, 'value', 1),
      );
      expect(
        answerFromJson(listDef, answerToJson(MultiListAnswer(definition: listDef, value: [1, 0]))),
        isA<MultiListAnswer>().having((a) => a.value, 'value', [1, 0]),
      );

      final boolDef = BoolAnswerDefinition(
        input: [
          const BoolInputDefinition(osmTags: {'a': 'yes'}),
          const BoolInputDefinition(osmTags: {'a': 'no'}),
        ],
        constructor: constructor,
      );
      expect(
        answerFromJson(boolDef, answerToJson(BoolAnswer(definition: boolDef, value: false))),
        isA<BoolAnswer>().having((a) => a.value, 'value', false),
      );

      const durationDef = DurationAnswerDefinition(
        input: DurationInputDefinition(
          days: (step: 1, display: false, output: false),
          hours: (step: 1, display: true, output: true),
          minutes: (step: 1, display: true, output: true),
          seconds: (step: 1, display: false, output: false),
        ),
        constructor: constructor,
      );
      expect(
        answerFromJson(
          durationDef,
          answerToJson(const DurationAnswer(definition: durationDef, value: Duration(minutes: 90))),
        ),
        isA<DurationAnswer>().having((a) => a.value, 'value', const Duration(minutes: 90)),
      );
    });

    test('answers not matching the definition are rejected', () {
      const stringDef = StringAnswerDefinition(input: StringInputDefinition(), constructor: constructor);
      expect(answerFromJson(stringDef, {'type': 'Bool', 'value': true}), isNull);
      expect(answerFromJson(stringDef, {'type': 'String', 'value': 1}), isNull);
    });
  });

  group('question ids', () {
    Map<String, dynamic> entry(String text) => {
      'question': {'name': '@name', 'text': text},
      'conditions': [
        {'osm_tags': {'highway': 'bus_stop'}},
      ],
      'answer': {
        'type': 'Bool',
        'input': [
          {'osm_tags': {'bench': 'yes'}},
          {'osm_tags': {'bench': 'no'}},
        ],
      },
    };

    test('ids are calculated from the untranslated entry', () {
      final raw = entry('@text');
      final german = QuestionCatalogReader.translateQuestionEntry(raw, [
        {'name': 'Bank', 'text': 'Gibt es eine Bank?'},
      ])! as Map<String, dynamic>;
      final english = QuestionCatalogReader.translateQuestionEntry(raw, [
        {'name': 'Bench', 'text': 'Is there a bench?'},
      ])! as Map<String, dynamic>;

      expect((german['question'] as Map)['text'], 'Gibt es eine Bank?');
      expect((english['question'] as Map)['name'], 'Bench');

      final id = QuestionDefinition.idFromJSON(raw);
      final germanCatalog = QuestionCatalog.fromEntries([(id: id, json: german)]);
      final englishCatalog = QuestionCatalog.fromEntries([(id: id, json: english)]);
      expect(germanCatalog.single, equals(englishCatalog.single));
      expect(germanCatalog.findById(id), isNotNull);
    });

    test('a changed definition gets a new id', () {
      expect(
        QuestionDefinition.idFromJSON(entry('@text')),
        isNot(QuestionDefinition.idFromJSON(entry('@other_text'))),
      );
    });

    test('identical definitions are only added once', () {
      final catalog = QuestionCatalog.fromJson([entry('@text'), entry('@text'), entry('@other')]);
      expect(catalog, hasLength(2));
    });
  });
}
