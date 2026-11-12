import 'dart:async';
import 'dart:io';

import '/api/panoramax_authentication_api.dart';
import '/api/panoramax_photo_upload_api.dart';
import '/l10n/app_localizations.g.dart';
import '/models/answer.dart';
import '/models/authenticated_user.dart';
import '/models/element_variants/element_identifier.dart';
import '/models/map_features/map_features.dart';
import '/models/question_catalog/question_catalog_reader.dart';
import '/models/questionnaire.dart';
import '/models/questionnaire_store.dart';
import '/utils/service_worker.dart';
import '/utils/stream_utils.dart';
import 'element_handler.dart';
import 'locale_handler.dart';
import 'question_catalog_handler.dart';

/// Handles questions to element matching and allows uploading the made changes.

mixin QuestionnaireHandler<M>
    on ServiceWorker<M>, QuestionCatalogHandler<M>, ElementHandler<M>, LocaleHandler<M> {
  final _questionnaireStore = QuestionnaireStore();

  Questionnaire? _activeQuestionnaire;

  final _activeQuestionnaireStreamController = StreamController<QuestionnaireRepresentation?>();

  /// A MultiStream that returns the current questionnaire state if any on initial subscription.
  ///
  /// Null means there is no active questionnaire.

  late final activeQuestionnaireStream = _activeQuestionnaireStreamController.stream
      .makeMultiStream((controller) {
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

  Future<void> openQuestionnaire(ElementIdentifier element) async {
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

  Future<void> _deletePhotos(Questionnaire questionnaire) async {
    for (final photo
        in questionnaire.entries
            .map((entry) => entry.answer)
            .whereType<PhotoAnswer>()
            .expand((answer) => answer.value)) {
      try {
        await photo.deleteFromDisk();
      } on FileSystemException {
        continue;
      }
    }
  }

  /// Remove a previously stored questionnaire associated to the provided element.
  ///
  /// Returns true if a corresponding questionnaire was found and discarded.

  Future<bool> discardQuestionnaireByElement(ElementIdentifier osmElement) async {
    final questionnaire = _questionnaireStore.find(
      (questionnaire) => questionnaire.workingElement == osmElement,
    );
    if (questionnaire != null) {
      await discardQuestionnaire(questionnaire);
      return true;
    }
    return false;
  }

  /// Remove a previously stored questionnaire.

  Future<void> discardQuestionnaire(Questionnaire questionnaire) async {
    _questionnaireStore.remove(questionnaire);
    await _deletePhotos(questionnaire);

    if (questionnaire == _activeQuestionnaire) {
      // unset current questionnaire
      _activeQuestionnaire = null;
      // notify change
      _activeQuestionnaireStreamController.add(null);
    }
  }

  /// Uploads the current questionnaire and closes its dialog before transmission.

  Future<void> uploadQuestionnaire(AuthenticatedUser user) async {
    final questionnaire = _activeQuestionnaire;
    if (questionnaire == null) return;
    closeQuestionnaire();

    final photos = questionnaire.entries
        .map((entry) => entry.answer)
        .whereType<PhotoAnswer>()
        .where((answer) => answer.isValid)
        .expand((answer) => answer.value)
        .toList();
    if (photos.isNotEmpty) {
      final authentication = user.panoramaxAuthentication;
      if (authentication == null) throw const PanoramaxAuthenticationException();
      final api = PanoramaxPhotoUploadAPI(authentication: authentication);
      try {
        final target = MapFeatures().representElement(questionnaire.workingElement);
        await api.upload(
          photos: photos,
          target: questionnaire.workingElement,
          label: target.elementLabel(lookupAppLocalizations(appLocale)),
        );
      } finally {
        api.dispose();
      }
    }
    await uploadElement(questionnaire.workingElement, user);
    await discardQuestionnaire(questionnaire);
  }

  void previousQuestion() {
    if (_activeQuestionnaire != null) {
      if (_questionnaireStore.isFinished(_activeQuestionnaire!)) {
        _questionnaireStore.markAsUnfinished(_activeQuestionnaire!);
      } else {
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
      } else if (_questionnaireStore.isUnfinished(_activeQuestionnaire!)) {
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
  Future<void> updateQuestionCatalog(QuestionCatalogChange questionCatalogChange) {
    final ret = super.updateQuestionCatalog(questionCatalogChange);

    if (questionCatalogChange.change == QuestionCatalogChangeReason.language) {
      // Update all QuestionDefinition of all the stored questionnares
      final questionnaireList = _questionnaireStore.items;

      for (final questionnaire in questionnaireList) {
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
    } else {
      for (final questionnaire in _questionnaireStore.items) {
        unawaited(_deletePhotos(questionnaire));
      }
      _questionnaireStore.clear();
      closeQuestionnaire();
    }
    return ret;
  }
}

/// An immutable representation of a Questionnaire used to present a snapshot of its state.

class QuestionnaireRepresentation {
  final List<QuestionnaireEntry> entries;

  final int activeIndex;

  final bool isCompleted;
  final int? osmId;
  final String? osmType;

  bool matchesTarget(ElementIdentifier? target) =>
      target != null && osmId == target.id && osmType == target.type.name;

  QuestionnaireRepresentation({
    required this.entries,
    required this.activeIndex,
    this.isCompleted = false,
    this.osmId,
    this.osmType,
  });

  QuestionnaireRepresentation.derive(Questionnaire questionnaire, {this.isCompleted = false})
    : osmId = questionnaire.workingElement.id,
      osmType = questionnaire.workingElement.type.name,
      entries = questionnaire.entries,
      activeIndex = questionnaire.activeIndex;
}
