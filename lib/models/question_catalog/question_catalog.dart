import 'dart:collection';
import 'question_definition.dart';

/// This class resembles an iterable of questions.

class QuestionCatalog with ListMixin<QuestionDefinition> {

  final List<QuestionDefinition> _questions;

  const QuestionCatalog(this._questions);


  QuestionCatalog.fromJson(Iterable<Map<String, dynamic>> json) :
    _questions = json.indexed
    .map<QuestionDefinition>((q) => QuestionDefinition.fromJSON(q.$1, q.$2))
    .toList(growable: false);

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
