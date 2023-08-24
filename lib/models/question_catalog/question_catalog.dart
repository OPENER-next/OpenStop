import 'dart:collection';
import 'question_definition.dart';

/// This class resembles an iterable of questions.

class QuestionCatalog with ListMixin<QuestionDefinition> {

  /// Whether professional questions should be excluded from this catalog or not.

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

enum QuestionCatalogChangeReason {
    language,
    definition,
}

class QuestionCatalogChange {
  final QuestionCatalog catalog;
  final QuestionCatalogChangeReason change;

  QuestionCatalogChange({
    required this.catalog,
    required this.change,
  });   

  QuestionCatalogChange.derive(this.catalog, this.change);
}

