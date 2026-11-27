import 'package:flutter_test/flutter_test.dart';
import 'package:open_stop/models/answer.dart';
import 'package:open_stop/models/element_conditions/element_condition.dart';
import 'package:open_stop/models/element_conditions/sub_condition_matcher.dart';
import 'package:open_stop/models/element_variants/base_element.dart';
import 'package:open_stop/models/question_catalog/answer_constructor.dart';
import 'package:open_stop/models/question_catalog/answer_definition.dart';
import 'package:open_stop/models/question_catalog/question_catalog.dart';
import 'package:open_stop/models/question_catalog/question_definition.dart';
import 'package:open_stop/models/questionnaire.dart';
import 'package:osm_api/osm_api.dart';

void main() async {
  const stringAnswer = StringAnswerDefinition(
    input: StringInputDefinition(),
    constructor: AnswerConstructor({
      'tag_a': [r'$input'],
    }),
  );

  final dummyCatalog = QuestionCatalog([
    QuestionDefinition(
      id: 'q0',
      name: 'q1',
      question: 'q1',
      conditions: [
        ElementCondition([
          TagsSubCondition.fromJson({'tag_a': false}),
        ]),
      ],
      answer: stringAnswer,
    ),
    QuestionDefinition(
      id: 'q1',
      name: 'q2',
      question: 'q2',
      conditions: [
        ElementCondition([
          TagsSubCondition.fromJson({'tag_a': '1'}),
        ]),
      ],
      answer: stringAnswer,
    ),
    QuestionDefinition(
      id: 'q2',
      name: 'q2',
      question: 'q2',
      conditions: [
        ElementCondition([
          TagsSubCondition.fromJson({'tag_a': '2'}),
        ]),
      ],
      answer: stringAnswer,
    ),
  ]);

  test('test if succeeding questions get correctly removed when pre-condition changes', () {
    final element = ProcessedNode(
      OSMNode(
        0,
        0,
        tags: {
          'other_tag': 'val',
        },
      ),
    );

    final questionnaire = Questionnaire(osmElement: element, questionCatalog: dummyCatalog);

    expect(questionnaire.length, equals(1));
    expect(questionnaire.activeIndex, equals(0));
    expect(questionnaire.workingElement.tags, equals({'other_tag': 'val'}));

    questionnaire.update(const StringAnswer(definition: stringAnswer, value: '1'));
    questionnaire.next();

    expect(questionnaire.length, equals(2));
    expect(questionnaire.activeIndex, equals(1));
    expect(questionnaire.workingElement.tags, equals({'other_tag': 'val', 'tag_a': '1'}));

    questionnaire.update(const StringAnswer(definition: stringAnswer, value: '2'));
    questionnaire.next();

    expect(questionnaire.length, equals(3));
    expect(questionnaire.activeIndex, equals(2));
    expect(questionnaire.workingElement.tags, equals({'other_tag': 'val', 'tag_a': '2'}));

    questionnaire.jumpTo(0);

    expect(questionnaire.length, equals(3));
    expect(questionnaire.activeIndex, equals(0));
    expect(questionnaire.workingElement.tags, equals({'other_tag': 'val', 'tag_a': '2'}));

    questionnaire.update(const StringAnswer(definition: stringAnswer, value: 'OTHER'));

    expect(questionnaire.length, equals(1));
    expect(questionnaire.activeIndex, equals(0));
    expect(questionnaire.workingElement.tags, equals({'other_tag': 'val', 'tag_a': 'OTHER'}));

    expect(questionnaire.next(), isFalse);
  });

  group('restore', () {
    ProcessedNode createElement() => ProcessedNode(OSMNode(0, 0, tags: {'other_tag': 'val'}));

    Questionnaire answeredQuestionnaire() {
      final questionnaire = Questionnaire(osmElement: createElement(), questionCatalog: dummyCatalog);
      questionnaire.update(const StringAnswer(definition: stringAnswer, value: '1'));
      questionnaire.next();
      questionnaire.update(const StringAnswer(definition: stringAnswer, value: 'x'));
      return questionnaire;
    }

    test('serialized answers are restored in order', () {
      final original = answeredQuestionnaire();
      expect(
        original.serializedAnswers.map((a) => a.questionId),
        equals(['q0', 'q1']),
      );

      final dropped = <String>[];
      final restored = Questionnaire.restore(
        osmElement: createElement(),
        questionCatalog: dummyCatalog,
        answers: original.serializedAnswers,
        onDropped: (id, _) => dropped.add(id),
      );

      expect(dropped, isEmpty);
      expect(restored.activeIndex, equals(0));
      expect(restored.length, equals(original.length));
      expect(restored.workingElement.tags, equals(original.workingElement.tags));
      // records containing maps are compared by identity, so compare their parts
      expect(
        restored.serializedAnswers.map((a) => (a.questionId, a.answer.toString())),
        equals(original.serializedAnswers.map((a) => (a.questionId, a.answer.toString()))),
      );
    });

    test('answers of questions missing in the catalog are dropped', () {
      final original = answeredQuestionnaire();
      final dropped = <String>[];
      final restored = Questionnaire.restore(
        osmElement: createElement(),
        // q1 was changed, so its id is no longer part of the catalog
        questionCatalog: QuestionCatalog([dummyCatalog[0], dummyCatalog[2]]),
        answers: original.serializedAnswers,
        onDropped: (id, _) => dropped.add(id),
      );

      expect(dropped, equals(['q1']));
      expect(restored.workingElement.tags, equals({'other_tag': 'val', 'tag_a': '1'}));
      expect(restored.serializedAnswers.map((a) => a.questionId), equals(['q0']));
    });

    test('answers whose question no longer applies are dropped', () {
      final dropped = <String>[];
      Questionnaire.restore(
        // q2 only applies if tag_a is 2
        osmElement: createElement(),
        questionCatalog: dummyCatalog,
        answers: [
          (questionId: 'q0', answer: {'type': 'String', 'value': '1'}),
          (questionId: 'q2', answer: {'type': 'String', 'value': 'x'}),
        ],
        onDropped: (id, _) => dropped.add(id),
      );
      expect(dropped, equals(['q2']));
    });

    test('malformed answers are dropped', () {
      final dropped = <String>[];
      Questionnaire.restore(
        osmElement: createElement(),
        questionCatalog: dummyCatalog,
        answers: [
          (questionId: 'q0', answer: {'type': 'Bool', 'value': true}),
        ],
        onDropped: (id, _) => dropped.add(id),
      );
      expect(dropped, equals(['q0']));
    });
  });
}
