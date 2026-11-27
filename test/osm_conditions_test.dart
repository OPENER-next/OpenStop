import 'package:flutter_test/flutter_test.dart';
import 'package:open_stop/models/element_conditions/element_condition.dart';
import 'package:open_stop/models/element_conditions/sub_condition_matcher.dart';
import 'package:open_stop/models/element_variants/base_element.dart';
import 'package:osm_api/osm_api.dart';

void main() async {
  test('regex keys match any selected value', () {
    final element = ProcessedNode(OSMNode(0, 0, tags: {'A': '1', 'AA': '2', 'AAA': '3'}));
    expect(TagsSubCondition.fromJson({r'/^A+$/': '1'}).matches(element), isTrue);
    expect(TagsSubCondition.fromJson({r'/^A+$/': r'/^2$/'}).matches(element), isTrue);
    expect(TagsSubCondition.fromJson({r'/^A+$/': '4'}).matches(element), isFalse);
    expect(TagsSubCondition.fromJson({r'/^B+$/': true}).matches(element), isFalse);
    expect(TagsSubCondition.fromJson({r'/^B+$/': false}).matches(element), isTrue);
  });

  test('negation and an inverted value regex require all selected values to match', () {
    final condition = ElementCondition.fromJSON({
      'osm_tags': {'/^payment:/': true},
      '!osm_tags': {'/^payment:/': r'/^(?!yes$).*$/'},
    });
    ProcessedNode element(Map<String, String> tags) => ProcessedNode(OSMNode(0, 0, tags: tags));
    expect(condition.matches(element({'payment:cash': 'yes', 'payment:card': 'yes'})), isTrue);
    expect(condition.matches(element({'payment:cash': 'yes', 'payment:card': 'no'})), isFalse);
    expect(condition.matches(element({})), isFalse);
    final withoutExistence = ElementCondition.fromJSON({
      '!osm_tags': {'/^payment:/': r'/^(?!yes$).*$/'},
    });
    expect(withoutExistence.matches(element({})), isTrue);
  });

  final ele = ProcessedNode(
    OSMNode(
      0,
      0,
      tags: {
        'foo': 'bar',
        'bla': 'blub',
      },
    ),
  );

  test('test if the tag conditions matches the pre-defined element', () {
    {
      final cond = TagsSubCondition.fromJson({
        'foo': 'bar',
      });
      expect(cond.matches(ele), isTrue);
    }

    {
      final cond = TagsSubCondition.fromJson({
        'foo': true,
      });
      expect(cond.matches(ele), isTrue);
    }
    {
      final cond = TagsSubCondition.fromJson({
        'foo': ['value2', 'value3', true],
      });
      expect(cond.matches(ele), isTrue);
    }

    {
      final cond = TagsSubCondition.fromJson({
        'test': false,
      });
      expect(cond.matches(ele), isTrue);
    }
    {
      final cond = TagsSubCondition.fromJson({
        'test': ['value2', 'value3', false],
      });
      expect(cond.matches(ele), isTrue);
    }

    {
      final cond = TagsSubCondition.fromJson({
        'foo': false,
      });
      expect(cond.matches(ele), isFalse);
    }
    {
      final cond = TagsSubCondition.fromJson({
        'foo': ['value2', 'value3', false],
      });
      expect(cond.matches(ele), isFalse);
    }

    {
      final cond = TagsSubCondition.fromJson({
        'foo': ['value2', 'value3', 'bar'],
      });
      expect(cond.matches(ele), isTrue);
    }

    {
      final cond = TagsSubCondition.fromJson({
        'foo': r'/^b.*r$/',
      });
      expect(cond.matches(ele), isTrue);
    }
    {
      final cond = TagsSubCondition.fromJson({
        'foo': ['value2', 'value3', r'/^b.*r$/'],
      });
      expect(cond.matches(ele), isTrue);
    }

    {
      final cond = TagsSubCondition.fromJson({
        'foo': ['value2', 'value3', r'/^b.*r$/'],
        'bla': ['test', true],
        'test': false,
      });
      expect(cond.matches(ele), isTrue);
    }
  });
}
