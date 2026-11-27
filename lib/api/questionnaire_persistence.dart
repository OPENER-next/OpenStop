import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:osm_api/osm_api.dart';

import '/models/element_variants/element_identifier.dart';
import '/models/panoramax_photo.dart';
import '/utils/json_file_store.dart';

/// A questionnaire as stored on disk.
///
/// It is bound to the [version] of the element it was answered for.

class SavedQuestionnaire {
  final OSMElementType type;
  final int id;
  final int version;
  final bool finished;
  final List<({String questionId, Map<String, dynamic> answer})> answers;

  /// The Panoramax upload set if the photos are already uploaded while the OSM changes are not.
  final String? photoUploadSetId;

  const SavedQuestionnaire({
    required this.type,
    required this.id,
    required this.version,
    required this.finished,
    required this.answers,
    this.photoUploadSetId,
  });

  String get key => keyOf(type, id);

  static String keyOf(OSMElementType type, int id) => '${type.name}/$id';

  static String keyOfElement(ElementIdentifier element) => keyOf(element.type, element.id);

  /// The paths of all photo files referenced by the answers.

  Iterable<String> get photoPaths => answers
      .where((entry) => entry.answer['type'] == 'Photo')
      .expand((entry) => (entry.answer['value'] as List).cast<Map<String, dynamic>>())
      .map((photo) => photo['file'] as String);

  factory SavedQuestionnaire.fromJson(Map<String, dynamic> json) => SavedQuestionnaire(
    type: OSMElementType.values.byName(json['type'] as String),
    id: json['id'] as int,
    version: json['version'] as int,
    finished: json['finished'] as bool,
    answers: [
      for (final entry in (json['answers'] as List).cast<Map<String, dynamic>>())
        (
          questionId: entry['question'] as String,
          answer: entry['answer'] as Map<String, dynamic>,
        ),
    ],
    photoUploadSetId: json['photoUploadSet'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'id': id,
    'version': version,
    'finished': finished,
    'answers': [
      for (final (:questionId, :answer) in answers) {'question': questionId, 'answer': answer},
    ],
    if (photoUploadSetId != null) 'photoUploadSet': photoUploadSetId,
  };
}

/// Reads and writes all [SavedQuestionnaire]s from a single file in the application support directory.

class QuestionnairePersistence {
  QuestionnairePersistence({
    @visibleForTesting JsonFileStore? store,
  }) : _store = store ?? JsonFileStore('questionnaires.json');

  final JsonFileStore _store;

  Future<Map<String, SavedQuestionnaire>> load() async {
    final result = <String, SavedQuestionnaire>{};
    final json = await _store.read();
    if (json is! List) return result;
    for (final entry in json) {
      try {
        final saved = SavedQuestionnaire.fromJson(entry as Map<String, dynamic>);
        result[saved.key] = saved;
      } catch (e) {
        debugPrint('Skip invalid saved questionnaire: $e');
      }
    }
    return result;
  }

  Future<void> save(Iterable<SavedQuestionnaire> questionnaires) {
    return _store.write([for (final questionnaire in questionnaires) questionnaire.toJson()]);
  }

  /// Deletes all photo files that are not referenced by any of the given questionnaires.
  ///
  /// Photos are only referenced once their answer is saved,
  /// therefore recently created photos are kept, because they might still be in use.

  static Future<void> deleteOrphanedPhotos(
    Iterable<SavedQuestionnaire> questionnaires, {
    Duration minAge = const Duration(hours: 1),
  }) async {
    final referenced = questionnaires
        .expand((q) => q.photoPaths)
        .map((path) => File(path).absolute.path)
        .toSet();
    final dir = await PanoramaxPhoto.storageDirectory;
    if (!dir.existsSync()) return;
    final threshold = DateTime.now().subtract(minAge);
    await for (final entity in dir.list()) {
      if (entity is File &&
          !referenced.contains(entity.absolute.path) &&
          entity.lastModifiedSync().isBefore(threshold)) {
        try {
          await entity.delete();
        } on FileSystemException catch (e) {
          debugPrint('Could not delete orphaned photo $entity: $e');
        }
      }
    }
  }
}
