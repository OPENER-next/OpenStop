import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import '/utils/service_worker.dart';
import '/models/question_catalog/question_catalog.dart';

mixin QuestionCatalogHandler<M> on ServiceWorker<M> {
  static final _completer = Completer<QuestionCatalog>();

  void takeQuestionCatalogAsset(ByteData data, ByteData dataT) {
    final questionCatalogTranslations =
        json.decode(utf8.decode(dataT.buffer.asUint8List()));
    final jsonString = utf8.decode(data.buffer.asUint8List());
    final jsonData = json.decode(
      jsonString,
      reviver: (key, value) {
        if (value is String && value.startsWith('@')) {
          if (questionCatalogTranslations[value.substring(1)] != null) {
            return questionCatalogTranslations[value.substring(1)];
          } else {
            return value;
          }
        } else {
          return value;
        }
      },
    );

    _completer.complete(
        QuestionCatalog.fromJson(jsonData.cast<Map<String, dynamic>>()));
  }

  var _questionCatalog = _completer.future;

  Future<QuestionCatalog> get questionCatalog => _questionCatalog;

  /// Note: currently this won't update any existing questionnaires.
  /// Only the creation of subsequent questionnaires will be affected by this.

  Future<void> updateQuestionCatalogPreferences(
      {required bool excludeProfessional}) async {
    final qc = await _questionCatalog;
    _questionCatalog = Future.value(
      qc.copyWith(excludeProfessional: excludeProfessional),
    );
  }
}
