import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_stop/api/osm_element_query_api.dart';
import 'package:open_stop/api/questionnaire_persistence.dart';
import 'package:open_stop/api/uploaded_elements_overlay.dart';
import 'package:open_stop/models/stop_area/stop_area.dart';
import 'package:open_stop/utils/file_cache.dart';
import 'package:open_stop/utils/json_file_store.dart';
import 'package:osm_api/osm_api.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('offline_storage_test');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('FileCache', () {
    FileCache createCache(Duration ttl) => FileCache(
      timeToLive: ttl,
      folderName: 'cache',
      baseDirectory: () async => tempDir,
    );

    test('writes and reads entries atomically', () async {
      final cache = createCache(const Duration(days: 1));
      await cache.writeBytes('a', utf8.encode('hello'));
      expect(utf8.decode((await cache.readBytes('a'))!), 'hello');
      expect(await cache.isFresh('a'), isTrue);
      // no temporary file is left behind
      expect(
        Directory('${tempDir.path}/cache').listSync().map((f) => f.uri.pathSegments.last),
        equals(['a']),
      );
    });

    test('a failed write keeps the previous entry', () async {
      final cache = createCache(const Duration(days: 1));
      await cache.writeBytes('a', utf8.encode('old'));
      await expectLater(
        cache.write('a', Stream.error(Exception('interrupted'))),
        throwsException,
      );
      expect(utf8.decode((await cache.readBytes('a'))!), 'old');
    });

    test('evictStale removes expired entries and leftover temporary files', () async {
      final cache = createCache(Duration.zero);
      await cache.writeBytes('expired', [1]);
      File('${tempDir.path}/cache/broken.tmp').writeAsBytesSync([1, 2, 3]);
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await cache.evictStale();
      expect(Directory('${tempDir.path}/cache').listSync(), isEmpty);
    });

    test('missing entries are stale', () async {
      final cache = createCache(const Duration(days: 1));
      expect(await cache.isStale('missing'), isTrue);
      expect(await cache.readBytes('missing'), isNull);
    });
  });

  group('CachedOSMElementQueryAPI', () {
    test('cache key depends only on the stop area bounds', () {
      final a = StopArea(const LatLng(1, 2), const LatLng(3, 4), name: 'A');
      final b = StopArea(const LatLng(1, 2), const LatLng(3, 4), name: 'B');
      final c = StopArea(const LatLng(1, 2), const LatLng(3, 4.0001));
      expect(CachedOSMElementQueryAPI.cacheKey(a), CachedOSMElementQueryAPI.cacheKey(b));
      expect(CachedOSMElementQueryAPI.cacheKey(a), isNot(CachedOSMElementQueryAPI.cacheKey(c)));
    });

    test('fresh cache entries are returned without network access', () async {
      final cache = FileCache(
        timeToLive: const Duration(days: 1),
        baseDirectory: () async => tempDir,
      );
      final stopArea = StopArea(const LatLng(1, 2), const LatLng(3, 4));
      final bundle = OSMElementBundle(nodes: [OSMNode(1.5, 2.5, id: 7, version: 2, tags: {'a': 'b'})]);
      await cache.writeBytes(
        CachedOSMElementQueryAPI.cacheKey(stopArea),
        gzip.encode(utf8.encode(jsonEncode(bundle.toJSONObject()))),
      );
      // unreachable end point, any network request would fail
      final api = CachedOSMElementQueryAPI(endPoint: 'http://127.0.0.1:1', cache: cache);
      final result = await api.queryByStopArea(stopArea);
      expect(result.nodes, equals(bundle.nodes));
      api.dispose();
    });
  });

  group('UploadedElementsOverlay', () {
    final now = DateTime(2026, 11, 26);

    UploadedElementsOverlay createOverlay([DateTime? time]) => UploadedElementsOverlay(
      timeToLive: const Duration(days: 7),
      store: JsonFileStore('overlay.json', baseDirectory: () async => tempDir),
      clock: () => time ?? now,
    );

    test('replaces older cached versions by the uploaded version', () async {
      await createOverlay().record(OSMNode(1, 2, id: 1, version: 3, tags: {'bench': 'yes'}));

      // new instance to verify persistence
      final overlay = createOverlay();
      final patched = await overlay.apply(
        OSMElementBundle(nodes: [OSMNode(1, 2, id: 1, version: 2), OSMNode(1, 2, id: 2, version: 1)]),
      );
      final node = patched.nodes.firstWhere((n) => n.id == 1);
      expect(node.version, 3);
      expect(node.tags, {'bench': 'yes'});
      expect(node.lat, 1);
      expect(patched.nodes.firstWhere((n) => n.id == 2).version, 1);
    });

    test('drops entries once a newer version was downloaded', () async {
      final overlay = createOverlay();
      await overlay.record(OSMNode(1, 2, id: 1, version: 3, tags: {'bench': 'yes'}));
      await overlay.apply(OSMElementBundle(nodes: [OSMNode(1, 2, id: 1, version: 4)]));
      // an older cached copy is no longer patched
      final patched = await overlay.apply(OSMElementBundle(nodes: [OSMNode(1, 2, id: 1, version: 2)]));
      expect(patched.nodes.single.version, 2);
    });

    test('drops entries older than the time to live', () async {
      await createOverlay().record(OSMNode(1, 2, id: 1, version: 3));
      final later = createOverlay(now.add(const Duration(days: 8)));
      final patched = await later.apply(OSMElementBundle(nodes: [OSMNode(1, 2, id: 1, version: 2)]));
      expect(patched.nodes.single.version, 2);
    });
  });

  group('QuestionnairePersistence', () {
    test('saves and loads questionnaires', () async {
      final persistence = QuestionnairePersistence(
        store: JsonFileStore('questionnaires.json', baseDirectory: () async => tempDir),
      );
      const saved = SavedQuestionnaire(
        type: OSMElementType.way,
        id: 42,
        version: 3,
        finished: true,
        answers: [
          (questionId: 'abc', answer: {'type': 'Bool', 'value': true}),
        ],
        photoUploadSetId: 'set',
      );
      await persistence.save([saved]);
      final loaded = await persistence.load();
      expect(loaded.keys, ['way/42']);
      final restored = loaded['way/42']!;
      expect(restored.version, 3);
      expect(restored.finished, isTrue);
      expect(restored.photoUploadSetId, 'set');
      expect(restored.answers.single.questionId, 'abc');
      expect(restored.answers.single.answer, {'type': 'Bool', 'value': true});
    });

    test('invalid files are ignored', () async {
      File('${tempDir.path}/questionnaires.json').writeAsStringSync('{not json');
      final persistence = QuestionnairePersistence(
        store: JsonFileStore('questionnaires.json', baseDirectory: () async => tempDir),
      );
      expect(await persistence.load(), isEmpty);
    });
  });
}
