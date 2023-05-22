import 'dart:async';

import '/api/app_worker/stop_area_handler.dart';
import '/utils/service_worker.dart';

import 'element_handler.dart';
import 'map_feature_handler.dart';
import 'question_catalog_handler.dart';
import 'questionnaire_handler.dart';

/// Main worker for the app.
///
/// It handles all the heavy lifting like downloading and uploading stop areas and elements, generating stop areas, filtering elements etc.
///
/// Since this runs in a separate thread this won't block the UI. Since any data send from the worker to the main isolate is copied one should only send immutable data to avoid any coding problems.
///
/// The isolate persists so it can cache any queried or processed data.

class AppWorker extends ServiceWorker<AppWorkerMessage>
  with MapFeatureHandler, QuestionCatalogHandler, StopAreaHandler, ElementHandler, QuestionnaireHandler {

  AppWorker(super.sendPort);

  @override
  Future<dynamic> messageHandler(message) async {
    switch(message.subject) {
      case AppWorkerSubject.passAssets:
        takeMapFeatureCollectionAsset(message.data[0]);
        takeQuestionCatalogAsset(message.data[1]);
        return;

      case AppWorkerSubject.queryStopAreas:
        return queryStopAreas(message.data);

      case AppWorkerSubject.queryElements:
        return queryElements(message.data);

      case AppWorkerSubject.openQuestionnaire:
        return openQuestionnaire(message.data);
      case AppWorkerSubject.updateQuestionnaire:
        return updateQuestionnaire(message.data);
      case AppWorkerSubject.closeQuestionnaire:
        return closeQuestionnaire();
      case AppWorkerSubject.discardQuestionnaire:
        return discardQuestionnaire(message.data);
      case AppWorkerSubject.uploadQuestionnaire:
        return uploadQuestionnaire(message.data);
      case AppWorkerSubject.nextQuestion:
        return nextQuestion();
      case AppWorkerSubject.previousQuestion:
        return previousQuestion();
      case AppWorkerSubject.jumpToQuestion:
        return jumpToQuestion(message.data);

      case AppWorkerSubject.dispose:
        return exit();

      default:
        throw UnimplementedError('The given message subject is not implemented');
    }
  }

  @override
  Stream subscriptionHandler(subscription) {
    switch(subscription.subject) {
      case AppWorkerSubject.subscribeStopAreas:
        return stopAreasStream;
      case AppWorkerSubject.subscribeLoadingChunks:
        return loadingCellsStream;
      case AppWorkerSubject.subscribeElements:
        return elementStream;
      case AppWorkerSubject.subscribeQuestionnaireChanges:
        return activeQuestionnaireStream;
      default:
        throw UnimplementedError('The given subscription subject is not implemented');
    }
  }
}


enum AppWorkerSubject {
  passAssets,

  subscribeLoadingChunks,
  subscribeStopAreas,
  queryStopAreas,

  subscribeElements,
  queryElements,

  subscribeQuestionnaireChanges,
  openQuestionnaire,
  updateQuestionnaire,
  closeQuestionnaire,
  discardQuestionnaire,
  uploadQuestionnaire,
  nextQuestion,
  previousQuestion,
  jumpToQuestion,

  dispose,
}


class AppWorkerMessage {
  final AppWorkerSubject subject;
  final dynamic data;

  AppWorkerMessage(this.subject, [ this.data ]);
}
