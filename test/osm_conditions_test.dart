import 'package:flutter_test/flutter_test.dart';
import 'package:open_stop/models/element_conditions/sub_condition_matcher.dart';
import 'package:open_stop/models/element_variants/base_element.dart';
import 'package:osm_api/osm_api.dart';

void main() async {

  final ele = ProcessedNode(OSMNode(0, 0, tags: {
    'foo': 'bar',
    'bla': 'blub',
  }));


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
        'foo': [ 'value2', 'value3', true ],
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
        'test': [ 'value2', 'value3', false ],
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
        'foo': [ 'value2', 'value3', false ],
      });
      expect(cond.matches(ele), isFalse);
    }

    {
      final cond = TagsSubCondition.fromJson({
        'foo': [ 'value2', 'value3', 'bar' ],
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
        'foo': [ 'value2', 'value3', r'/^b.*r$/' ],
      });
      expect(cond.matches(ele), isTrue);
    }

    {
      final cond = TagsSubCondition.fromJson({
        'foo': [ 'value2', 'value3', r'/^b.*r$/' ],
        'bla': [ 'test', true ],
        'test': false,
      });
      expect(cond.matches(ele), isTrue);
    }
  });
}
