import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '/api/authentication/panoramax_authentication_api.dart';
import '/api/panoramax_photo_upload_api.dart';
import '/api/questionnaire_persistence.dart';
import '/models/answer.dart';
import '/models/authenticated_user.dart';
import '/models/element_variants/base_element.dart';
import '/models/element_variants/element_identifier.dart';
import '/models/question_catalog/question_catalog.dart';
import '/models/question_catalog/question_catalog_reader.dart';
import '/models/questionnaire.dart';
import '/models/questionnaire_store.dart';
import '/models/tag_diff.dart';
import '/utils/service_worker.dart';
import '/utils/stream_utils.dart';
import 'element_handler.dart';
import 'question_catalog_handler.dart';

/// Handles questions to element matching and allows uploading the made changes.
///
/// Questionnaires with at least one valid answer are saved to disk and restored
/// once their element is loaded again, as long as the element version didn't change.

mixin QuestionnaireHandler<M> on ServiceWorker<M>, QuestionCatalogHandler<M>, ElementHandler<M> {
  final _questionnaireStore = QuestionnaireStore();

  Questionnaire? _activeQuestionnaire;

  final _activeQuestionnaireStreamController = StreamController<QuestionnaireRepresentation?>();

  final _persistence = QuestionnairePersistence();

  /// Saved questionnaires whose elements haven't been loaded yet.

  late final Future<Map<String, SavedQuestionnaire>> _unrestored = _loadSavedQuestionnaires();

  Timer? _persistTimer;

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

  Future<Map<String, SavedQuestionnaire>> _loadSavedQuestionnaires() async {
    try {
      final saved = await _persistence.load();
      unawaited(
        QuestionnairePersistence.deleteOrphanedPhotos(saved.values).catchError(
          (Object e) => debugPrint('Could not clean up photos: $e'),
        ),
      );
      return saved;
    } catch (e) {
      debugPrint('Could not load saved questionnaires: $e');
      return {};
    }
  }

  @override
  bool hasFinishedQuestionnaire(ElementIdentifier element) {
    final questionnaire = _findQuestionnaire(element);
    return questionnaire != null && _questionnaireStore.isFinished(questionnaire);
  }

  @override
  Future<void> onElementsLoaded(Iterable<ProcessedElement> elements) async {
    await super.onElementsLoaded(elements);
    final unrestored = await _unrestored;
    if (unrestored.isEmpty) return;

    final catalog = await questionCatalog;
    var changed = false;

    for (final element in elements) {
      final saved = unrestored.remove(SavedQuestionnaire.keyOfElement(element));
      if (saved == null) continue;
      changed = true;
      // keep any questionnaire that was created in the meantime
      if (_findQuestionnaire(element) != null) continue;
      // answers only apply to the element version they were given for
      if (saved.version != element.version) {
        await _deleteFiles(saved.photoPaths);
        continue;
      }
      _restore(element, catalog, saved.answers, saved.finished, saved.photoUploadSetId);
    }

    if (changed) _schedulePersist();
  }

  /// Rebuilds a questionnaire from the given answers and adds it to the store.
  ///
  /// Answers that no longer fit the catalog are dropped. In this case a finished questionnaire becomes unfinished.

  void _restore(
    ProcessedElement element,
    QuestionCatalog catalog,
    Iterable<({String questionId, Map<String, dynamic> answer})> answers,
    bool finished,
    String? photoUploadSetId,
  ) {
    var droppedAny = false;
    final questionnaire = Questionnaire.restore(
      osmElement: element,
      questionCatalog: catalog,
      answers: answers,
      onDropped: (_, answer) {
        droppedAny = true;
        if (answer['type'] == 'Photo') {
          final paths = (answer['value'] as List).map((photo) => (photo as Map)['file'] as String);
          unawaited(_deleteFiles(paths));
        }
      },
    );
    if (questionnaire.serializedAnswers.isEmpty) return;
    _questionnaireStore.add(questionnaire, finished: finished && !droppedAny);
    _questionnaireStore.setPhotoUploadSet(questionnaire, photoUploadSetId);
  }

  static Future<void> _deleteFiles(Iterable<String> paths) async {
    for (final path in paths) {
      try {
        final file = File(path);
        if (file.existsSync()) await file.delete();
      } on FileSystemException catch (e) {
        debugPrint('Could not delete $path: $e');
      }
    }
  }

  Questionnaire? _findQuestionnaire(ElementIdentifier element) {
    return _questionnaireStore.find(
      (questionnaire) => questionnaire.workingElement == element,
    );
  }

  /// Saves all questionnaires shortly after the last change.

  void _schedulePersist() {
    _persistTimer?.cancel();
    _persistTimer = Timer(const Duration(milliseconds: 300), () => unawaited(_persist()));
  }

  Future<void> _persist() async {
    _persistTimer?.cancel();
    _persistTimer = null;
    final unrestored = await _unrestored;
    final saved = [
      ...unrestored.values,
      for (final questionnaire in _questionnaireStore.items)
        if (questionnaire.serializedAnswers.isNotEmpty)
          SavedQuestionnaire(
            type: questionnaire.originalElement.type,
            id: questionnaire.originalElement.id,
            version: questionnaire.originalElement.version,
            finished: _questionnaireStore.isFinished(questionnaire),
            answers: questionnaire.serializedAnswers,
            photoUploadSetId: _questionnaireStore.photoUploadSetOf(questionnaire),
          ),
    ];
    await _persistence.save(saved);
  }

  void _notifyActiveQuestionnaire() {
    _activeQuestionnaireStreamController.add(
      QuestionnaireRepresentation.derive(
        _activeQuestionnaire!,
        isCompleted: _questionnaireStore.isFinished(_activeQuestionnaire!),
      ),
    );
  }

  /// Updates the map marker of the given questionnaire's element if its finished state changed.

  void _refreshMarker(Questionnaire questionnaire, bool wasFinished) {
    if (wasFinished != _questionnaireStore.isFinished(questionnaire)) {
      unawaited(refreshElement(questionnaire.originalElement));
    }
  }

  /// This either reopens an existing questionnaire or creates a new one.
  ///
  /// A finished questionnaire is reopened at its summary, so it can be uploaded right away.

  Future<void> openQuestionnaire(ElementIdentifier element) async {
    final internalElement = findElement(element);
    if (internalElement == null) return;

    _activeQuestionnaire = _findQuestionnaire(internalElement);

    if (_activeQuestionnaire == null) {
      _activeQuestionnaire = Questionnaire(
        osmElement: internalElement,
        questionCatalog: await questionCatalog,
      );
      _questionnaireStore.add(_activeQuestionnaire!);
    }

    if (_questionnaireStore.isUnfinished(_activeQuestionnaire!)) {
      // instead of restoring the last questionnaire index always restart from the beginning
      _activeQuestionnaire!.jumpTo(0);
    }
    _notifyActiveQuestionnaire();
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
      _notifyActiveQuestionnaire();
      _schedulePersist();
    }
  }

  /// Remove a previously stored questionnaire associated to the provided element.
  ///
  /// Returns true if a corresponding questionnaire was found and discarded.

  Future<bool> discardQuestionnaireByElement(ElementIdentifier osmElement) async {
    final questionnaire = _findQuestionnaire(osmElement);
    if (questionnaire != null) {
      await discardQuestionnaire(questionnaire);
      return true;
    }
    return false;
  }

  /// Remove a previously stored questionnaire.

  Future<void> discardQuestionnaire(Questionnaire questionnaire) async {
    final wasFinished = _questionnaireStore.isFinished(questionnaire);
    await _questionnaireStore.remove(questionnaire);
    await _persist();
    if (wasFinished) unawaited(refreshElement(questionnaire.originalElement));

    if (questionnaire == _activeQuestionnaire) {
      // unset current questionnaire
      _activeQuestionnaire = null;
      // notify change
      _activeQuestionnaireStreamController.add(null);
    }
  }

  /// Uploads the active questionnaire. This also automatically closes the questionnaire.
  ///
  /// The OSM changes are first checked for conflicts, then photos are uploaded
  /// and finally the OSM changes are written.
  /// If the OSM changes cannot be written, already uploaded photos are deleted again.
  ///
  /// On failure the questionnaire is kept (and stays finished) so the upload can be retried later.
  /// On an [ElementConflictException] the questionnaire is discarded.

  Future<void> uploadQuestionnaire(
    AuthenticatedUser<int> user,
    AuthenticatedUser<String>? photoUser,
  ) async {
    final questionnaire = _activeQuestionnaire!;
    final element = _activeQuestionnaire!.workingElement;
    // close questionnaire before uploading
    closeQuestionnaire();

    final photos = questionnaire.entries
        .map((entry) => entry.answer)
        .whereType<PhotoAnswer>()
        .where((answer) => answer.isValid)
        .expand((answer) => answer.value)
        .toList();

    if (photos.isNotEmpty && photoUser == null) throw const PanoramaxAuthenticationException();
    final photoApi = photos.isEmpty
        ? null
        : PanoramaxPhotoUploadAPI(
            authentication: photoUser!.authentication,
            endPoint: '${photoUser.instance}/api',
          );

    Future<void> uploadPhotos() async {
      // photos might already be uploaded by a previous attempt that was interrupted
      if (photoApi == null || _questionnaireStore.photoUploadSetOf(questionnaire) != null) return;
      final uploadSetId = await photoApi.upload(photos: photos, target: element);
      _questionnaireStore.setPhotoUploadSet(questionnaire, uploadSetId);
      await _persist();
    }

    try {
      await uploadElement(element, user, beforePublish: uploadPhotos);
    } on ElementConflictException {
      // the changes can no longer be applied, the questions will be asked again if still relevant
      await _deleteUploadedPhotos(questionnaire, photoApi);
      await discardQuestionnaire(questionnaire);
      rethrow;
    } catch (_) {
      await _deleteUploadedPhotos(questionnaire, photoApi);
      rethrow;
    } finally {
      photoApi?.dispose();
    }
    await discardQuestionnaire(questionnaire);
  }

  /// Deletes the photos that were uploaded for a questionnaire whose OSM changes could not be written.
  /// If the deletion fails the upload set is kept, so a retry doesn't upload the photos again.

  Future<void> _deleteUploadedPhotos(
    Questionnaire questionnaire,
    PanoramaxPhotoUploadAPI? photoApi,
  ) async {
    final uploadSetId = _questionnaireStore.photoUploadSetOf(questionnaire);
    if (uploadSetId == null || photoApi == null) return;
    if (await photoApi.deleteUploadSet(uploadSetId)) {
      _questionnaireStore.setPhotoUploadSet(questionnaire, null);
      await _persist();
    }
  }

  void previousQuestion() {
    if (_activeQuestionnaire != null) {
      final wasFinished = _questionnaireStore.isFinished(_activeQuestionnaire!);
      if (wasFinished) {
        _questionnaireStore.markAsUnfinished(_activeQuestionnaire!);
      } else {
        _activeQuestionnaire!.previous();
      }
      _notifyActiveQuestionnaire();
      _refreshMarker(_activeQuestionnaire!, wasFinished);
      _schedulePersist();
    }
  }

  void nextQuestion() {
    if (_activeQuestionnaire != null) {
      final hasNext = _activeQuestionnaire!.next();

      if (hasNext) {
        _notifyActiveQuestionnaire();
      } else if (_questionnaireStore.isUnfinished(_activeQuestionnaire!)) {
        _questionnaireStore.markAsFinished(_activeQuestionnaire!);
        _notifyActiveQuestionnaire();
        _refreshMarker(_activeQuestionnaire!, false);
        _schedulePersist();
      }
    }
  }

  void jumpToQuestion(int index) {
    if (_activeQuestionnaire != null) {
      final wasFinished = _questionnaireStore.isFinished(_activeQuestionnaire!);
      _activeQuestionnaire!.jumpTo(index);
      _questionnaireStore.markAsUnfinished(_activeQuestionnaire!);
      _notifyActiveQuestionnaire();
      _refreshMarker(_activeQuestionnaire!, wasFinished);
      _schedulePersist();
    }
  }

  @override
  void exit() {
    if (_persistTimer != null) unawaited(_persist());
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
        _notifyActiveQuestionnaire();
      }
    } else {
      closeQuestionnaire();
      // rebuild all questionnaires with the new catalog
      // answers of questions that were changed or removed are dropped
      for (final questionnaire in _questionnaireStore.items.toList()) {
        final wasFinished = _questionnaireStore.isFinished(questionnaire);
        final photoUploadSetId = _questionnaireStore.photoUploadSetOf(questionnaire);
        _questionnaireStore.detach(questionnaire);
        _restore(
          questionnaire.originalElement,
          questionCatalogChange.catalog,
          questionnaire.serializedAnswers,
          wasFinished,
          photoUploadSetId,
        );
      }
      _schedulePersist();
    }
    return ret;
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

  QuestionnaireRepresentation.derive(Questionnaire questionnaire, {this.isCompleted = false})
    : entries = questionnaire.entries,
      activeIndex = questionnaire.activeIndex;
}
