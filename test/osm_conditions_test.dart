import 'package:flutter_test/flutter_test.dart';
import 'package:open_stop/models/element_variants/base_element.dart';
import 'package:open_stop/models/osm_condition.dart';
import 'package:osm_api/osm_api.dart';

void main() async {

  final ele = ProcessedNode(OSMNode(0, 0, tags: {
    'foo': 'bar',
    'bla': 'blub',
  }));


  test('test if the tag conditions matches the pre-defined element', () {
    {
      const cond = OsmCondition(
        osmTags: {
          'foo': 'bar',
        },
      );
      expect(cond.matches(ele), isTrue);
    }

    {
      const cond = OsmCondition(
        osmTags: {
          'foo': true,
        },
      );
      expect(cond.matches(ele), isTrue);
    }
    {
      const cond = OsmCondition(
        osmTags: {
          'foo': [ 'value2', 'value3', true ],
        },
      );
      expect(cond.matches(ele), isTrue);
    }

    {
      const cond = OsmCondition(
        osmTags: {
          'test': false,
        },
      );
      expect(cond.matches(ele), isTrue);
    }
    {
      const cond = OsmCondition(
        osmTags: {
          'test': [ 'value2', 'value3', false ],
        },
      );
      expect(cond.matches(ele), isTrue);
    }

    {
      const cond = OsmCondition(
        osmTags: {
          'foo': false,
        },
      );
      expect(cond.matches(ele), isFalse);
    }
    {
      const cond = OsmCondition(
        osmTags: {
          'foo': [ 'value2', 'value3', false ],
        },
      );
      expect(cond.matches(ele), isFalse);
    }

    {
      const cond = OsmCondition(
        osmTags: {
          'foo': [ 'value2', 'value3', 'bar' ],
        },
      );
      expect(cond.matches(ele), isTrue);
    }

    {
      final cond = OsmCondition(
        osmTags: {
          'foo': RegExp(r'^b.*r$'),
        },
      );
      expect(cond.matches(ele), isTrue);
    }
    {
      final cond = OsmCondition(
        osmTags: {
          'foo': [ 'value2', 'value3', RegExp(r'^b.*r$') ],
        },
      );
      expect(cond.matches(ele), isTrue);
    }

    {
      final cond = OsmCondition(
        osmTags: {
          'foo': [ 'value2', 'value3', RegExp(r'^b.*r$') ],
          'bla': [ 'test', true ],
          'test': false,
        },
      );
      expect(cond.matches(ele), isTrue);
    }
  });
}
