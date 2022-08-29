import 'package:collection/collection.dart';

import 'questionnaire.dart';

/// Stores questionnaires and allows marking them as finished or unfinished.

class QuestionnaireStore {
  final _questionnaires = <Questionnaire, bool>{};

  int get length => _questionnaires.length;

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

  void remove(Questionnaire questionnaire) {
    _questionnaires.remove(questionnaire);
  }

  Questionnaire? find(bool Function(Questionnaire) callback) {
    return _questionnaires.keys.firstWhereOrNull(callback);
  }
}
