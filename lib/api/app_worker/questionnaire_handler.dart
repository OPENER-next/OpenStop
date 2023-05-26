import 'dart:async';
import 'dart:ui';

import '/models/authenticated_user.dart';
import '/models/element_variants/element_identifier.dart';
import '/api/osm_element_upload_api.dart';
import '/models/answer.dart';
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

  /// Null means there is no active questionnaire.

  Stream<QuestionnaireRepresentation?> get activeQuestionnaireStream => _activeQuestionnaireStreamController.stream;

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

  Future<void> uploadQuestionnaire(ElementUploadData data) async {
    final questionnaire = _activeQuestionnaire!;
    final element = _activeQuestionnaire!.workingElement;
    final stopArea = findCorrespondingStopArea(element);
    // close questionnaire before uploading
    closeQuestionnaire();

    // upload with first StopArea occurrence
    final uploadAPI = OSMElementUploadAPI(
      mapFeatureCollection: await mapFeatureCollection,
      stopArea: stopArea,
      authenticatedUser: data.user,
      changesetLocale: data.locale.languageCode,
    );
    try {
      await element.publish(uploadAPI);
      discardQuestionnaire(questionnaire);
      // trigger element representation updates
      updateElementAndDependents(element);
    }
    finally {
      uploadAPI.dispose();
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

  QuestionnaireRepresentation.derive(Questionnaire questionnaire, {this.isCompleted = false }) :
    entries = questionnaire.entries,
    activeIndex = questionnaire.activeIndex;
}


class ElementUploadData {
  final AuthenticatedUser user;

  final Locale locale;

  const ElementUploadData({
    required this.user,
    required this.locale,
  });
}
