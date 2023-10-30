import 'dart:async';

import '/models/question_catalog/question_catalog_reader.dart';
import '/models/authenticated_user.dart';
import '/models/element_variants/element_identifier.dart';
import '/models/answer.dart';
import '/utils/stream_utils.dart';
import '/utils/service_worker.dart';
import '/models/questionnaire_store.dart';
import '/models/questionnaire.dart';
import 'element_handler.dart';
import 'question_catalog_handler.dart';

/// Handles questions to element matching and allows uploading the made changes.

mixin QuestionnaireHandler<M> on ServiceWorker<M>, QuestionCatalogHandler<M>, ElementHandler<M> {
  final _questionnaireStore = QuestionnaireStore();

  Questionnaire? _activeQuestionnaire;

  final _activeQuestionnaireStreamController = StreamController<QuestionnaireRepresentation?>();

  /// A MultiStream that returns the current questionnaire state if any on initial subscription.
  ///
  /// Null means there is no active questionnaire.

  late final activeQuestionnaireStream = _activeQuestionnaireStreamController.stream.makeMultiStream((controller) {
    if (_activeQuestionnaire != null) {
      controller.addSync(
        QuestionnaireRepresentation.derive(
          _activeQuestionnaire!,
          isCompleted: _questionnaireStore.isFinished(_activeQuestionnaire!),
        ),
      );
    }
  });

  /// This either reopens an existing questionnaire or creates a new one.

  void openQuestionnaire(ElementIdentifier element) async {
    final internalElement = findElement(element);
    if (internalElement == null) return;

    _activeQuestionnaire = _questionnaireStore.find(
      (questionnaire) => questionnaire.workingElement == internalElement,
    );

    if (_activeQuestionnaire == null) {
      _activeQuestionnaire = Questionnaire(
        osmElement: internalElement,
        questionCatalog: await questionCatalog,
      );
      _questionnaireStore.add(_activeQuestionnaire!);
    }

    // instead of restoring the last questionnaire index always restart from the beginning
    _activeQuestionnaire!.jumpTo(0);
    _questionnaireStore.markAsUnfinished(_activeQuestionnaire!);
    // notify change
    _activeQuestionnaireStreamController.add(
      QuestionnaireRepresentation.derive(_activeQuestionnaire!),
    );
  }

  /// Close the currently active questionnaire if any.

  void closeQuestionnaire() {
    if (_activeQuestionnaire != null) {
      // unset current questionnaire
      _activeQuestionnaire = null;
      // notify change
      _activeQuestionnaireStreamController.add(null);
    }
  }

  void updateQuestionnaire(Answer? answer) {
    if (_activeQuestionnaire != null) {
      _activeQuestionnaire!.update(answer);
      // notify change
      _activeQuestionnaireStreamController.add(
        QuestionnaireRepresentation.derive(
          _activeQuestionnaire!,
          isCompleted: _questionnaireStore.isFinished(_activeQuestionnaire!),
        ),
      );
    }
  }

  /// Remove a previously stored questionnaire associated to the provided element.
  ///
  /// Returns true if a corresponding questionnaire was found and discarded.

  bool discardQuestionnaireByElement(ElementIdentifier osmElement) {
    final questionnaire = _questionnaireStore.find(
      (questionnaire) => questionnaire.workingElement == osmElement,
    );
    if (questionnaire != null) {
      discardQuestionnaire(questionnaire);
      return true;
    }
    return false;
  }

  /// Remove a previously stored questionnaire.

  void discardQuestionnaire(Questionnaire questionnaire) {
    _questionnaireStore.remove(questionnaire);

    if (questionnaire == _activeQuestionnaire) {
      // unset current questionnaire
      _activeQuestionnaire = null;
      // notify change
      _activeQuestionnaireStreamController.add(null);
    }
  }

  /// This also automatically closes the questionnaire.

  Future<void> uploadQuestionnaire(AuthenticatedUser user) async {
    final questionnaire = _activeQuestionnaire!;
    final element = _activeQuestionnaire!.workingElement;
    // close questionnaire before uploading
    closeQuestionnaire();
    final success = await uploadElement(element, user);
    if (success) {
      discardQuestionnaire(questionnaire);
    }
  }

  void previousQuestion() {
    if (_activeQuestionnaire != null) {
      if (_questionnaireStore.isFinished(_activeQuestionnaire!)) {
        _questionnaireStore.markAsUnfinished(_activeQuestionnaire!);
      }
      else {
        _activeQuestionnaire!.previous();
      }
      // notify change
      _activeQuestionnaireStreamController.add(
        QuestionnaireRepresentation.derive(_activeQuestionnaire!),
      );
    }
  }

  void nextQuestion() {
    if (_activeQuestionnaire != null) {
      final hasNext = _activeQuestionnaire!.next();

      if (hasNext) {
        _activeQuestionnaireStreamController.add(
          QuestionnaireRepresentation.derive(_activeQuestionnaire!),
        );
      }
      else if (_questionnaireStore.isUnfinished(_activeQuestionnaire!)) {
        _questionnaireStore.markAsFinished(_activeQuestionnaire!);
        // notify change
        _activeQuestionnaireStreamController.add(
          QuestionnaireRepresentation.derive(_activeQuestionnaire!, isCompleted: true),
        );
      }
    }
  }

  void jumpToQuestion(int index) {
    if (_activeQuestionnaire != null) {
      _activeQuestionnaire!.jumpTo(index);
      _questionnaireStore.markAsUnfinished(_activeQuestionnaire!);
      // notify change
      _activeQuestionnaireStreamController.add(
        QuestionnaireRepresentation.derive(_activeQuestionnaire!),
      );
    }
  }

  @override
  void exit() {
    _activeQuestionnaireStreamController.close();
    super.exit();
  }

  @override
  void updateQuestionCatalog(QuestionCatalogChange questionCatalogChange) {
    super.updateQuestionCatalog(questionCatalogChange);

    if (questionCatalogChange.change == QuestionCatalogChangeReason.language) {
      // Update all QuestionDefinition of all the stored questionnares
      final questionnaireList = _questionnaireStore.items;

      for (final Questionnaire questionnaire in questionnaireList) {
        questionnaire.updateQuestionCatalogLanguage(questionCatalogChange.catalog);
      }
      // Update current _activeQuestionnaire
      if (_activeQuestionnaire != null) {
        // notify change
        _activeQuestionnaireStreamController.add(
          QuestionnaireRepresentation.derive(
            _activeQuestionnaire!,
            isCompleted: _questionnaireStore.isFinished(_activeQuestionnaire!),
          ),
        );
      }
    }
    else {
      _questionnaireStore.clear();
      closeQuestionnaire();
    }
  }
}

/// An immutable representation of a Questionnaire used to present a snapshot of its state.

class QuestionnaireRepresentation {
  final List<QuestionnaireEntry> entries;

  final int activeIndex;

  final bool isCompleted;

  QuestionnaireRepresentation({
    required this.entries,
    required this.activeIndex,
    this.isCompleted = false,
  });

  QuestionnaireRepresentation.derive(Questionnaire questionnaire, {this.isCompleted = false}) :
    entries = questionnaire.entries,
    activeIndex = questionnaire.activeIndex;
}
