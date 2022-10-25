import 'dart:collection';

import 'question_definition.dart';

/// This class resembles an iterable of questions.

class QuestionCatalog with IterableMixin<QuestionDefinition> {

  /// Wether professional questions should be excluded from this catalog or not.

  final bool excludeProfessional;

  final List<QuestionDefinition> _questions;

  const QuestionCatalog(this._questions, {
    this.excludeProfessional = false
  });


  factory QuestionCatalog.fromJson(List<Map<String, dynamic>> json) {
    final questionList = List<QuestionDefinition>.unmodifiable(
      json.map<QuestionDefinition>(QuestionDefinition.fromJSON)
    );
    return QuestionCatalog(questionList);
  }


  Iterable<QuestionDefinition> get reversed => _questions.reversed.where(_isIncluded);


  @override
  Iterator<QuestionDefinition> get iterator => _ComparingIterator(
    _questions, _isIncluded
  );


  bool _isIncluded(QuestionDefinition question) {
    return !excludeProfessional || !question.isProfessional;
  }


  QuestionCatalog copyWith({
    bool? excludeProfessional,
  }) => QuestionCatalog(
    _questions,
    excludeProfessional: excludeProfessional ?? this.excludeProfessional,
  );
}


class _ComparingIterator<T> implements Iterator<T> {
  final List<T> _items;

  final bool Function(T element) compare;

  int _index = -1;

  _ComparingIterator(this._items, this.compare);

  @override
  bool moveNext() {
    while (++_index < _items.length) {
      if (compare(_items[_index])) {
        return true;
      }
    }
    return false;
  }

  @override
  T get current => _items[_index];
}
