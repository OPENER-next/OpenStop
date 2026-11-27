import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'question_definition.dart';

/// This class resembles an iterable of questions.

class QuestionCatalog with ListMixin<QuestionDefinition> {
  final List<QuestionDefinition> _questions;

  const QuestionCatalog(this._questions);

  /// Creates a catalog from untranslated (or untranslatable) question entries.

  QuestionCatalog.fromJson(Iterable<Map<String, dynamic>> json)
    : this.fromEntries(json.map((entry) => (id: QuestionDefinition.idFromJSON(entry), json: entry)));

  /// Creates a catalog from translated question entries with ids calculated from their untranslated version.
  ///
  /// Questions with identical ids (identical definitions) are only added once.

  QuestionCatalog.fromEntries(Iterable<({String id, Map<String, dynamic> json})> entries)
    : _questions = _unique(entries)
          .map<QuestionDefinition>((entry) => QuestionDefinition.fromJSON(entry.id, entry.json))
          .toList(growable: false);

  static Iterable<({String id, Map<String, dynamic> json})> _unique(
    Iterable<({String id, Map<String, dynamic> json})> entries,
  ) {
    final ids = <String>{};
    return entries.where((entry) {
      final isNew = ids.add(entry.id);
      if (!isNew) debugPrint('Skip duplicated question definition: ${entry.json}');
      return isNew;
    });
  }

  /// Find a question by its [QuestionDefinition.id].

  QuestionDefinition? findById(String id) {
    for (final question in _questions) {
      if (question.id == id) return question;
    }
    return null;
  }

  @override
  int get length => _questions.length;

  @override
  set length(int newLength) {
    throw UnsupportedError('Question catalog is immutable. Length cannot be changed.');
  }

  @override
  QuestionDefinition operator [](int index) => _questions[index];

  @override
  void operator []=(int index, QuestionDefinition value) {
    throw UnsupportedError('Question catalog is immutable. Cannot modify items.');
  }
}
