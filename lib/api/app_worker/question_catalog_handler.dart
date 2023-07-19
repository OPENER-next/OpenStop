import 'dart:async';
import 'package:flutter/material.dart';

import '/utils/service_worker.dart';
import '/models/question_catalog/question_catalog.dart';

mixin QuestionCatalogHandler<M> on ServiceWorker<M> {
  static final _completer = Completer<QuestionCatalog>();

  @mustCallSuper
  void updateQuestionCatalog(QuestionCatalog questionCatalog) {
    if (_completer.isCompleted) {
      _questionCatalog = Future.value(questionCatalog);
    } else {
      _completer.complete(questionCatalog);
    }
  }

  var _questionCatalog = _completer.future;

  Future<QuestionCatalog> get questionCatalog => _questionCatalog;

  /// Note: currently this won't update any existing questionnaires.
  /// Only the creation of subsequent questionnaires will be affected by this.

}
