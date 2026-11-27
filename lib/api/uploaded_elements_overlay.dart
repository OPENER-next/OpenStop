import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:osm_api/osm_api.dart';

import '/utils/json_file_store.dart';

/// Remembers the version and tags of elements uploaded by this app
/// so that older copies of them in the element cache can be updated when loaded.
///
/// This avoids rewriting every cached stop area file that contains an uploaded element.
/// Only tags are changed by the app, therefore geometries never need to be patched.
///
/// An entry can be dropped once it is older than the [timeToLive] of the element cache,
/// because by then every cache file written before the upload has expired.

class UploadedElementsOverlay {
  UploadedElementsOverlay({
    required this.timeToLive,
    @visibleForTesting JsonFileStore? store,
    @visibleForTesting DateTime Function()? clock,
  }) : _store = store ?? JsonFileStore('element_cache/uploaded_elements.json'),
       _clock = clock ?? DateTime.now;

  final Duration timeToLive;

  final JsonFileStore _store;

  final DateTime Function() _clock;

  late final Future<Map<String, _Entry>> _entries = _load();

  Future<Map<String, _Entry>> _load() async {
    final entries = <String, _Entry>{};
    try {
      final json = await _store.read();
      if (json is Map<String, dynamic>) {
        for (final MapEntry(:key, :value) in json.entries) {
          entries[key] = _Entry.fromJson(value as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint('Could not read uploaded elements: $e');
    }
    final now = _clock();
    final sizeBefore = entries.length;
    entries.removeWhere((_, entry) => now.difference(entry.uploadedAt) > timeToLive);
    if (entries.length != sizeBefore) unawaited(_save(entries));
    return entries;
  }

  Future<void> _save(Map<String, _Entry> entries) {
    return _store.write({
      for (final MapEntry(:key, :value) in entries.entries) key: value.toJson(),
    });
  }

  static String _key(OSMElementType type, int id) => '${type.name}/$id';

  /// Records the state of an element after it was uploaded successfully.

  Future<void> record(OSMElement element) async {
    final entries = await _entries;
    entries[_key(element.type, element.id)] = _Entry(
      version: element.version,
      tags: Map.of(element.tags),
      uploadedAt: _clock(),
    );
    return _save(entries);
  }

  /// Returns a bundle in which all elements that are older than a recorded upload
  /// carry the uploaded version and tags.
  ///
  /// Entries for which the bundle already contains the same or a newer version are removed,
  /// because the bundle was evidently downloaded after the upload.

  Future<OSMElementBundle> apply(OSMElementBundle bundle) async {
    final entries = await _entries;
    if (entries.isEmpty) return bundle;

    var changed = false;
    OSMElement patch(OSMElement element) {
      final key = _key(element.type, element.id);
      final entry = entries[key];
      if (entry == null) return element;
      if (entry.version > element.version) {
        return element.copyWith(version: entry.version, tags: Map.of(entry.tags));
      }
      entries.remove(key);
      changed = true;
      return element;
    }

    // elements must not be mutated, because the bundle stores them in hash based sets
    final patched = OSMElementBundle.fromElements(bundle.elements.map(patch).toList());
    if (changed) unawaited(_save(entries));
    return patched;
  }
}

class _Entry {
  final int version;
  final Map<String, String> tags;
  final DateTime uploadedAt;

  const _Entry({
    required this.version,
    required this.tags,
    required this.uploadedAt,
  });

  factory _Entry.fromJson(Map<String, dynamic> json) => _Entry(
    version: json['version'] as int,
    tags: (json['tags'] as Map<String, dynamic>).cast<String, String>(),
    uploadedAt: DateTime.fromMillisecondsSinceEpoch(json['uploadedAt'] as int),
  );

  Map<String, dynamic> toJson() => {
    'version': version,
    'tags': tags,
    'uploadedAt': uploadedAt.millisecondsSinceEpoch,
  };
}
