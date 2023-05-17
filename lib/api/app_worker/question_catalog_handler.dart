import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import '/utils/service_worker.dart';
import '/models/question_catalog/question_catalog.dart';

mixin QuestionCatalogHandler<M> on ServiceWorker<M> {

  static final _completer = Completer<QuestionCatalog>();

  void takeQuestionCatalogAsset(ByteData data) {
    final jsonString = utf8.decode(data.buffer.asUint8List());
    final jsonData = json.decode(jsonString).cast<Map<String, dynamic>>();
    _completer.complete(QuestionCatalog.fromJson(jsonData));
  }

  final questionCatalog = _completer.future;
}
