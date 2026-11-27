import 'package:collection/collection.dart';

import 'answer.dart';
import 'questionnaire.dart';

/// Stores questionnaires and allows marking them as finished or unfinished.

class QuestionnaireStore {
  final _questionnaires = <Questionnaire, bool>{};

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

  void add(Questionnaire questionnaire) {
    _questionnaires[questionnaire] = false;
  }

  /// Removes the questionnaire and deletes the photos taken for it from disk.

  Future<void> remove(Questionnaire questionnaire) {
    _questionnaires.remove(questionnaire);
    return _deletePhotos([questionnaire]);
  }

  /// Removes all questionnaires and deletes the photos taken for them from disk.

  Future<void> clear() {
    final questionnaires = _questionnaires.keys.toList();
    _questionnaires.clear();
    return _deletePhotos(questionnaires);
  }

  static Future<void> _deletePhotos(Iterable<Questionnaire> questionnaires) {
    final photoDeletion = questionnaires
        .expand((questionnaire) => questionnaire.entries)
        .map((entry) => entry.answer)
        .whereType<PhotoAnswer>()
        .expand((answer) => answer.value)
        .map((photo) => photo.deleteFromDisk());
    // A photo that cannot be deleted is left behind in the temporary directory.
    return Future.wait(photoDeletion).then<void>((_) {}, onError: (_) {});
  }

  Questionnaire? find(bool Function(Questionnaire) callback) {
    return _questionnaires.keys.firstWhereOrNull(callback);
  }
}
