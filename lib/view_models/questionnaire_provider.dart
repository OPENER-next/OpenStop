import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart' hide ProxyElement;

import '/utils/debouncer.dart';
import '/models/element_variants/base_element.dart';
import '/models/questionnaire_store.dart';
import '/models/question_catalog/question_definition.dart';
import '/models/questionnaire.dart';
import '/models/question_catalog/question_catalog.dart';
import '/widgets/question_inputs/question_input_widget.dart';


class QuestionnaireProvider extends ChangeNotifier {

  final _questionnaireStore = QuestionnaireStore();

  Questionnaire? _activeQuestionnaire;

  final Map<QuestionnaireEntry, AnswerController> _answerControllerMapping = {};

  // used to throttle input changes

  final _answerInputDebouncer = Debouncer(const Duration(milliseconds: 500));

  ProxyElement? get workingElement => _activeQuestionnaire?.workingElement;

  int get questionCount => _activeQuestionnaire?.length ?? 0;

  bool get hasQuestions => questionCount > 0;

  bool get isOpen => _activeQuestionnaire != null;

  bool get isClosed => _activeQuestionnaire == null;

  /// Whether all questions of the current questionnaire have been visited.

  bool get isFinished {
    if (_activeQuestionnaire != null) {
      return _questionnaireStore.isFinished(_activeQuestionnaire!);
    }
    return false;
  }

  UnmodifiableListView<QuestionDefinition> get questions {
    return UnmodifiableListView(
      _activeQuestionnaire?.entries.map(
        (entry) => entry.question
      ) ?? const Iterable.empty()
    );
  }

  UnmodifiableListView<AnswerController> get answers {
    return UnmodifiableListView(
      _activeQuestionnaire?.entries.map(
        (entry) => _answerControllerMapping[entry]!
      ) ?? const Iterable.empty()
    );
  }

  int? get currentQuestionnaireIndex => _activeQuestionnaire?.activeIndex;

  /// An unique identifier for the current questionnaire

  Key get key => ValueKey(_activeQuestionnaire);

  /// This either reopens an existing questionnaire or creates a new one.

  void open(ProcessedElement osmElement, QuestionCatalog questionCatalog) {
    if (_activeQuestionnaire != null) {
      // store latest answer from previous questionnaire
      _updateQuestionnaireAnswer();
      // if a previous questionnaire exists, remove all answer controllers
      // this is necessary since the QuestionnaireEntry -> AnswerController mapping is only unique per questionnaire
      // other questionnaires might have the exact same QuestionnaireEntry and would therefore otherwise reuse previous AnswerControllers
      _activeQuestionnaire = null;
      _updateAnswerControllers();
    }

    _activeQuestionnaire = _questionnaireStore.find(
      (questionnaire) => questionnaire.workingElement == osmElement,
    );

    if (_activeQuestionnaire == null) {
      _activeQuestionnaire = Questionnaire(
        osmElement: osmElement,
        questionCatalog: questionCatalog
      );
      _questionnaireStore.add(_activeQuestionnaire!);
    }

    _updateAnswerControllers();

    // instead of restoring the last questionnaire index always restart from the beginning
    _activeQuestionnaire!.jumpTo(0);
    _questionnaireStore.markAsUnfinished(_activeQuestionnaire!);

    notifyListeners();
  }

  /// Close the currently active questionnaire if any.

  void close() {
    if (_activeQuestionnaire != null) {
      // store latest answer from questionnaire
      _updateQuestionnaireAnswer();
      // unset current questionnaire
      _activeQuestionnaire = null;
      _updateAnswerControllers();

      notifyListeners();
    }
  }

  /// Remove a previously stored questionnaire.

  void discard(ProxyElement osmElement) {
    final questionnaire = _questionnaireStore.find(
      (questionnaire) => questionnaire.workingElement == osmElement,
    );

    if (questionnaire != null) {
      _questionnaireStore.remove(questionnaire);

      if (questionnaire == _activeQuestionnaire) {
        // unset current questionnaire
        _activeQuestionnaire = null;
        _updateAnswerControllers();
      }
      notifyListeners();
    }
  }


  void previousQuestion() {
    if (_activeQuestionnaire != null) {
      if (_questionnaireStore.isFinished(_activeQuestionnaire!)) {
        _questionnaireStore.markAsUnfinished(_activeQuestionnaire!);
      }
      else {
        _updateQuestionnaireAnswer();
        _updateAnswerControllers();
        _activeQuestionnaire!.previous();
      }
      notifyListeners();
    }
  }


  void nextQuestion() {
    if (_activeQuestionnaire != null) {
      _updateQuestionnaireAnswer();
      _updateAnswerControllers();
      final hasNext = _activeQuestionnaire!.next();

      if (!hasNext && _questionnaireStore.isUnfinished(_activeQuestionnaire!)) {
        _questionnaireStore.markAsFinished(_activeQuestionnaire!);
      }
      notifyListeners();
    }
  }


  void jumpToQuestion(int index) {
    if (_activeQuestionnaire != null) {
      _updateQuestionnaireAnswer();
      _updateAnswerControllers();

      _activeQuestionnaire!.jumpTo(index);
      _questionnaireStore.markAsUnfinished(_activeQuestionnaire!);

      notifyListeners();
    }
  }


  /// Updates the questionnaire with the current answer.
  ///
  /// Calling this repeatedly might be expensive, since a questionnaire update
  /// will go through all questions and check whether they still match or start
  /// matching.
  ///
  /// The questionnaire is still updated on "go to next/previous question" calls.

  void _update() {
    if (_activeQuestionnaire != null ) {
      _updateQuestionnaireAnswer();
      _updateAnswerControllers();
      notifyListeners();
    }
  }

  /// Stores the answer of the current question in the questionnaire.
  /// This refreshes the questionnaire and may add new or remove obsolete questions.

  void _updateQuestionnaireAnswer() {
    // cancel any queued callbacks
    _answerInputDebouncer.cancel();
    final answerController = _answerControllerMapping[_activeQuestionnaire!.activeEntry];
    _activeQuestionnaire!.update(answerController!.answer);
  }

  /// Maps all [QuestionnaireEntry]s to typed [AnswerController]s.
  /// Should be called on every questionnaire "update".
  /// If no questionnaire is selected this will remove and dispose all left over answer controllers.

  void _updateAnswerControllers() {
    final questionEntries = _activeQuestionnaire?.entries ?? const <QuestionnaireEntry>[];
    // remove obsolete answer controllers
    _answerControllerMapping.removeWhere((questionEntry, controller) {
      if (!questionEntries.contains(questionEntry)) {
        controller.dispose();
        return true;
      }
      return false;
    });
    // add new answer controllers for each entry if none already exists
    for (final questionEntry in questionEntries) {
      _answerControllerMapping.putIfAbsent(
        questionEntry,
        () => AnswerController.fromType(
          type: questionEntry.question.answer.runtimeType,
          initialAnswer: questionEntry.answer,
        )..addListener(_answerInputDebouncer.debounce(_update))
      );
    }
  }


  @override
  void dispose() {
    _answerInputDebouncer.cancel();
    // dispose all answer controllers
    _activeQuestionnaire = null;
    _updateAnswerControllers();
    super.dispose();
  }
}
