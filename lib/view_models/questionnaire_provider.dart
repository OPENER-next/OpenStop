import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:osm_api/osm_api.dart';

import '/models/questionnaire.dart';
import '/models/proxy_osm_element.dart';
import '/models/answer.dart';
import '/models/question_catalog.dart';


class QuestionnaireProvider extends ChangeNotifier {

  final _questionnaires = <Questionnaire>[];

  var _currentQuestionnaireIndex = -1;

  Questionnaire? get _currentQuestionnaire {
    if (_currentQuestionnaireIndex > -1 && _currentQuestionnaireIndex < _questionnaires.length) {
      return _questionnaires[_currentQuestionnaireIndex];
    }
    return null;
  }


  bool get hasQuestions => questionCount > 0;


  ProxyOSMElement? get workingElement => _currentQuestionnaire?.workingElement;


  int get questionCount => _currentQuestionnaire?.length ?? 0;


  UnmodifiableListView<QuestionnaireEntry> get currentQuestions => _currentQuestionnaire?.entries ?? UnmodifiableListView([]);


  int? get activeQuestionIndex => _currentQuestionnaire?.activeIndex;

  QuestionnaireEntry? get activeQuestionEntry => _currentQuestionnaire?.activeEntry;


  /// An unique identifier for the current questionnaire

  Key get key => ValueKey(_currentQuestionnaire);

  /// This either reopens an existing questionnaire or creates a new one.

  void open(OSMElement osmElement, QuestionCatalog questionCatalog) {
    _currentQuestionnaireIndex = _questionnaires.indexWhere(
      (questionnaire) => questionnaire.workingElement.isOther(osmElement),
    );

    if (_currentQuestionnaireIndex == -1) {
      _questionnaires.add(Questionnaire(
        osmElement: osmElement,
        questionCatalog: questionCatalog
      ));
      _currentQuestionnaireIndex = _questionnaires.length - 1;
    }

    notifyListeners();
  }

  /// Close the currently active questionnaire if any.

  void close() {
    _currentQuestionnaireIndex = -1;
    notifyListeners();
  }

  /// Remove a previously stored questionnaire.

  void discard(ProxyOSMElement osmElement) {
    final index = _questionnaires.indexWhere(
      (questionnaire) => questionnaire.workingElement == osmElement,
    );

    if (index > -1) {
      _questionnaires.removeAt(index);
      // in case a questionnaire is currently active and its index is greater
      // then the removed index we need to update the index
      if (_currentQuestionnaireIndex > index) {
        _currentQuestionnaireIndex = _currentQuestionnaireIndex - 1;
      }
      notifyListeners();
    }
  }


  void answerQuestion(Answer? answer) {
    if (_currentQuestionnaire != null) {
      _currentQuestionnaire!.update(answer);
      notifyListeners();
    }
  }


  bool previousQuestion() {
    if (_currentQuestionnaire?.previous() == true) {
      notifyListeners();
      return true;
    }
    return false;
  }


  bool nextQuestion() {
    if (_currentQuestionnaire?.next() == true) {
      notifyListeners();
      return true;
    }
    return false;
  }


  bool jumpToQuestion(int index) {
    if (_currentQuestionnaire?.jumpTo(index) == true) {
      notifyListeners();
      return true;
    }
    return false;
  }
}
