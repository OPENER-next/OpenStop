import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_mvvm_architecture/base.dart';
import 'package:get_it/get_it.dart';

import '/models/element_variants/element_identifier.dart';
import '/models/authenticated_user.dart';
import '/models/answer.dart';
import '/utils/service_worker.dart';
import 'app_worker.dart';
import 'element_handler.dart';
import 'questionnaire_handler.dart';
import 'stop_area_handler.dart';

/// Interface for [AppWorker].
///
/// Instantiate the worker via the [spawn] method.
///
/// This is basically just a wrapper for the [send] and [subscribe] calls to the worker.

class AppWorkerInterface extends Service implements Disposable {
  final ServiceWorkerController<AppWorkerMessage> _worker;

  AppWorkerInterface._(this._worker);

  static Future<AppWorkerInterface> spawn() async {
    final con = await ServiceWorkerController.spawn<AppWorkerMessage>(AppWorker.new);
    return AppWorkerInterface._(con);
  }

  // required due to flutter limitation (see main.dart)

  Future<void> passAssets(List<ByteData> assets) {
    return _worker.send<void>(AppWorkerMessage(
      AppWorkerSubject.passAssets,
      assets,
    ));
  }

  // stop area related functions \\

  Stream<int> subscribeLoadingChunks() {
    return _worker.subscribe<int>(AppWorkerMessage(
      AppWorkerSubject.subscribeLoadingChunks,
    ));
  }

  Stream<StopAreaUpdate> subscribeStopAreas() {
    return _worker.subscribe<StopAreaUpdate>(AppWorkerMessage(
      AppWorkerSubject.subscribeStopAreas,
    ));
  }

  Future<void> queryStopAreas(LatLngBounds bounds) {
    return _worker.send<void>(AppWorkerMessage(
      AppWorkerSubject.queryStopAreas,
      bounds,
    ));
  }

  // element area related functions \\

  Future<void> queryElements(LatLngBounds bounds) {
    return _worker.send<void>(AppWorkerMessage(AppWorkerSubject.queryElements, bounds));
  }

  Stream<ElementUpdate> subscribeElements() {
    return _worker.subscribe<ElementUpdate>(AppWorkerMessage(
      AppWorkerSubject.subscribeElements,
    ));
  }

  // questionnaire related functions \\

  Stream<QuestionnaireState?> subscribeQuestionnaireChanges() {
    return _worker.subscribe<QuestionnaireState?>(AppWorkerMessage(
      AppWorkerSubject.subscribeQuestionnaireChanges,
    ));
  }

  Future<void> openQuestionnaire(ElementIdentifier element) {
    return _worker.send<void>(AppWorkerMessage(
      AppWorkerSubject.openQuestionnaire,
      element,
    ));
  }

  Future<void> updateQuestionnaire(Answer? answer) {
    return _worker.send<void>(AppWorkerMessage(
      AppWorkerSubject.updateQuestionnaire,
      answer,
    ));
  }
  Future<void> closeQuestionnaire() {
    return _worker.send<void>(AppWorkerMessage(
      AppWorkerSubject.closeQuestionnaire,
    ));
  }

  Future<void> discardQuestionnaire(ElementIdentifier element) {
    return _worker.send<void>(AppWorkerMessage(
      AppWorkerSubject.discardQuestionnaire,
      element,
    ));
  }

  Future<void> uploadQuestionnaire({
    required AuthenticatedUser user,
    required Locale locale,
  }) {
    return _worker.send<void>(AppWorkerMessage(AppWorkerSubject.uploadQuestionnaire, ElementUploadData(
      user: user,
      locale: locale,
    )));
  }


  Future<void> nextQuestion() {
    return _worker.send<void>(AppWorkerMessage(
      AppWorkerSubject.nextQuestion,
    ));
  }

  Future<void> previousQuestion() {
    return _worker.send<void>(AppWorkerMessage(
      AppWorkerSubject.previousQuestion,
    ));
  }

  Future<void> jumpToQuestion(int index) {
    return _worker.send<void>(AppWorkerMessage(
      AppWorkerSubject.jumpToQuestion,
      index,
    ));
  }

  /// Close the service worker when un-registering this service.

  @override
  FutureOr onDispose() {
    _worker.send(AppWorkerMessage(AppWorkerSubject.dispose));
  }
}
