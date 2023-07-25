import 'dart:async';
import 'package:flutter/material.dart';

import '/utils/service_worker.dart';
import '/models/question_catalog/question_catalog.dart';

mixin QuestionCatalogHandler<M> on ServiceWorker<M> {
  static final _completer = Completer<QuestionCatalog>();

  @mustCallSuper
  void updateQuestionCatalog(({QuestionCatalog questionCatalog, bool onlyLanguageChange}) questionCatalogChangeData) {
    if (_completer.isCompleted) {
      _questionCatalog = Future.value(questionCatalogChangeData.questionCatalog);
    } else {
      _completer.complete(questionCatalogChangeData.questionCatalog);
    }
  }

  var _questionCatalog = _completer.future;

  Future<QuestionCatalog> get questionCatalog => _questionCatalog;
}
