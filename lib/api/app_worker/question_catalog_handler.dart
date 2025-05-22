import 'dart:async';

import 'package:flutter/foundation.dart';

import '/models/question_catalog/question_catalog.dart';
import '/models/question_catalog/question_catalog_reader.dart';
import '/utils/service_worker.dart';

mixin QuestionCatalogHandler<M> on ServiceWorker<M> {
  static final _completer = Completer<QuestionCatalog>();

  @mustCallSuper
  void updateQuestionCatalog(QuestionCatalogChange questionCatalogChange) {
    if (_completer.isCompleted) {
      _questionCatalog = Future.value(questionCatalogChange.catalog);
    } else {
      _completer.complete(questionCatalogChange.catalog);
    }
  }

  var _questionCatalog = _completer.future;

  Future<QuestionCatalog> get questionCatalog => _questionCatalog;
}
