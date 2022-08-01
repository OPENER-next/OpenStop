import 'dart:collection';

import '/models/question.dart';

/// This class resembles an iterable of questions.

class QuestionCatalog with IterableMixin<Question> {

  /// Wether professional questions should be excluded from this catalog or not.

  final bool excludeProfessional;

  final List<Question> _questions;

  const QuestionCatalog(this._questions, {
    this.excludeProfessional = false
  });


  factory QuestionCatalog.fromJson(List<Map<String, dynamic>> json) {
    final questionList = List<Question>.unmodifiable(
      json.map<Question>(Question.fromJSON)
    );
    return QuestionCatalog(questionList);
  }


  Iterable<Question> get reversed => _questions.reversed.where(_isIncluded);


  @override
  Iterator<Question> get iterator => _ComparingIterator(
    _questions, _isIncluded
  );


  bool _isIncluded(Question question) {
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
