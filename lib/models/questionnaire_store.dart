import 'package:collection/collection.dart';

import 'answer.dart';
import 'questionnaire.dart';

/// Stores questionnaires and allows marking them as finished or unfinished.

class QuestionnaireStore {
  final _questionnaires = <Questionnaire, bool>{};

  /// The Panoramax upload set of questionnaires whose photos are already uploaded,
  /// while the OSM changes are not.

  final _photoUploadSets = <Questionnaire, String>{};

  int get length => _questionnaires.length;

  Iterable<Questionnaire> get items => _questionnaires.keys;

  bool isFinished(Questionnaire questionnaire) {
    return _questionnaires[questionnaire] ?? false;
  }

  bool isUnfinished(Questionnaire questionnaire) => !isFinished(questionnaire);

  void markAsFinished(Questionnaire questionnaire) {
    _questionnaires[questionnaire] = true;
  }

  void markAsUnfinished(Questionnaire questionnaire) {
    _questionnaires[questionnaire] = false;
  }

  void add(Questionnaire questionnaire, {bool finished = false}) {
    _questionnaires[questionnaire] = finished;
  }

  String? photoUploadSetOf(Questionnaire questionnaire) => _photoUploadSets[questionnaire];

  void setPhotoUploadSet(Questionnaire questionnaire, String? uploadSetId) {
    if (uploadSetId == null) {
      _photoUploadSets.remove(questionnaire);
    } else {
      _photoUploadSets[questionnaire] = uploadSetId;
    }
  }

  /// Removes the questionnaire and deletes the photos taken for it from disk.

  Future<void> remove(Questionnaire questionnaire) {
    _questionnaires.remove(questionnaire);
    _photoUploadSets.remove(questionnaire);
    return deletePhotos([questionnaire]);
  }

  /// Removes the questionnaire without deleting its photos.
  /// Used when the questionnaire is replaced by a restored version of itself.

  void detach(Questionnaire questionnaire) {
    _questionnaires.remove(questionnaire);
    _photoUploadSets.remove(questionnaire);
  }

  /// Removes all questionnaires and deletes the photos taken for them from disk.

  Future<void> clear() {
    final questionnaires = _questionnaires.keys.toList();
    _questionnaires.clear();
    _photoUploadSets.clear();
    return deletePhotos(questionnaires);
  }

  static Future<void> deletePhotos(Iterable<Questionnaire> questionnaires) {
    final photoDeletion = questionnaires
        .expand((questionnaire) => questionnaire.entries)
        .map((entry) => entry.answer)
        .whereType<PhotoAnswer>()
        .expand((answer) => answer.value)
        .map((photo) => photo.deleteFromDisk());
    // A photo that cannot be deleted is left behind and removed by the next orphan clean-up.
    return Future.wait(photoDeletion).then<void>((_) {}, onError: (_) {});
  }

  Questionnaire? find(bool Function(Questionnaire) callback) {
    return _questionnaires.keys.firstWhereOrNull(callback);
  }
}
