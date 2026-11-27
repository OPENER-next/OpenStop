import 'package:flutter_test/flutter_test.dart';
import 'package:open_stop/models/tag_diff.dart';
import 'package:osm_api/osm_api.dart';

void main() {
  group('TagDiff.between', () {
    test('detects added, modified and deleted tags', () {
      final diff = TagDiff.between(
        {'keep': 'a', 'change': 'old', 'remove': 'x'},
        {'keep': 'a', 'change': 'new', 'add': 'y'},
      );
      expect(diff.changes, hasLength(3));
      expect(
        diff.changes.whereType<TagAdd>().single,
        isA<TagAdd>().having((c) => c.key, 'key', 'add').having((c) => c.value, 'value', 'y'),
      );
      expect(
        diff.changes.whereType<TagModify>().single,
        isA<TagModify>()
            .having((c) => c.before, 'before', 'old')
            .having((c) => c.value, 'value', 'new'),
      );
      expect(diff.changes.whereType<TagDelete>().single.before, 'x');
    });

    test('is empty for equal tags', () {
      expect(TagDiff.between({'a': 'b'}, {'a': 'b'}).isEmpty, isTrue);
    });
  });

  group('TagDiff.applyTo', () {
    test('applies changes on top of unrelated changes made by others', () {
      final diff = TagDiff.between({'a': '1'}, {'a': '1', 'bench': 'yes'});
      expect(diff.applyTo({'a': '1', 'name': 'Other'}), {'a': '1', 'name': 'Other', 'bench': 'yes'});
    });

    test('add: same value set by someone else is not a conflict', () {
      const diff = TagDiff([TagAdd('bench', 'yes')]);
      expect(diff.applyTo({'bench': 'yes'}), {'bench': 'yes'});
    });

    test('add: different value set by someone else is a conflict', () {
      const diff = TagDiff([TagAdd('bench', 'yes')]);
      expect(() => diff.applyTo({'bench': 'no'}), throwsA(isA<ElementConflictException>()));
    });

    test('modify: unchanged or already applied value is not a conflict', () {
      const diff = TagDiff([TagModify('bench', 'no', 'yes')]);
      expect(diff.applyTo({'bench': 'no'}), {'bench': 'yes'});
      expect(diff.applyTo({'bench': 'yes'}), {'bench': 'yes'});
    });

    test('modify: third value or removed tag is a conflict', () {
      const diff = TagDiff([TagModify('bench', 'no', 'yes')]);
      expect(() => diff.applyTo({'bench': 'maybe'}), throwsA(isA<ElementConflictException>()));
      expect(() => diff.applyTo({}), throwsA(isA<ElementConflictException>()));
    });

    test('delete: missing key is not a conflict, changed value is', () {
      const diff = TagDiff([TagDelete('bench', 'yes')]);
      expect(diff.applyTo({}), isEmpty);
      expect(diff.applyTo({'bench': 'yes'}), isEmpty);
      expect(() => diff.applyTo({'bench': 'no'}), throwsA(isA<ElementConflictException>()));
    });

    test('does not modify the given tags', () {
      final tags = {'a': '1'};
      const TagDiff([TagAdd('b', '2')]).applyTo(tags);
      expect(tags, {'a': '1'});
    });
  });

  group('checkGeometryConflict', () {
    test('small node movement is no conflict', () {
      checkGeometryConflict(OSMNode(52.0, 13.0), OSMNode(52.0001, 13.0));
    });

    test('node movement above threshold is a conflict', () {
      expect(
        () => checkGeometryConflict(OSMNode(52.0, 13.0), OSMNode(52.001, 13.0)),
        throwsA(isA<ElementConflictException>()),
      );
    });

    test('ways are not checked', () {
      checkGeometryConflict(OSMWay([1, 2]), OSMWay([3, 4]));
    });
  });
}
