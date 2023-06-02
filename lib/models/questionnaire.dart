import 'dart:collection';

import '/models/question_catalog/question_catalog.dart';
import '/models/question_catalog/question_definition.dart';
import '/models/answer.dart';
import 'element_variants/base_element.dart';


class Questionnaire {

  Questionnaire({
    required ProcessedElement osmElement,
    required QuestionCatalog questionCatalog,
  }) :
    _questionCatalog = questionCatalog,
    _osmElement = osmElement
  {
    _updateWorkingElement();
    _insertMatchingEntries(afterIndex: -1);
  }

  final QuestionCatalog _questionCatalog;

  final List<QuestionnaireEntry> _entries = [];

  final ProcessedElement _osmElement;

  late ProxyElement _workingElement;

  int _activeIndex = 0;


  ProxyElement get workingElement => _workingElement;


  int get length => _entries.length;


  UnmodifiableListView<QuestionnaireEntry> get entries {
    return UnmodifiableListView(_entries);
  }


  int get activeIndex => _activeIndex;


  QuestionnaireEntry? get activeEntry =>
    _isValidIndex(_activeIndex) ? _entries[_activeIndex] : null;


  bool jumpTo(int index) {
    if (_isValidIndex(index) && index != _activeIndex) {
      _activeIndex = index;
      return true;
    }
    return false;
  }


  bool previous() {
    return jumpTo(_activeIndex - 1);
  }


  bool next() {
    return jumpTo(_activeIndex + 1);
  }


  void update<T extends Answer>(T? answer) {
    if (_isValidIndex(_activeIndex)) {
      _entries[_activeIndex] = QuestionnaireEntry(
        _entries[_activeIndex].question,
        answer
      );
      _removeObsoleteEntries();
      _updateWorkingElement();
      _insertMatchingEntries();
    }
  }


  bool _isValidIndex(int index) {
    return index >= 0 && _entries.length > index;
  }


  void _updateWorkingElement() {
    _workingElement = _createWorkingElement();
  }


  void _insertMatchingEntries({ int? afterIndex }) {
    afterIndex ??= _activeIndex;
    // insert questions in reverse so questions that follow next in the catalog
    // also follow next in the questionnaire
    for (final question in _questionCatalog.reversed) {
      // get whether the question conditions matches the current working element
      final questionIsMatching = question.conditions.any((condition) {
        return condition.matches(_workingElement);
      });

      if (questionIsMatching) {
        // check if there already exists an answer with the same question
        final index = _entries.indexWhere((entry) => entry.question == question);
        if (index == -1) {
          // insert new questions after the current active index
          _entries.insert(afterIndex + 1, QuestionnaireEntry(question));
        }
      }
    }
  }


  void _removeObsoleteEntries() {
    // Note: do not use reverse iteration here
    // because removing a previous entry might result in the removal of a following entry (and so forth)
    // which wouldn't be detected when iterating in reverse

    // only iterate over all elements after the current active index
    var i = _activeIndex + 1;

    while (i < _entries.length) {
      final entry = _entries[i];
      // create working element from all preceding entries excluding the current entry
      // this needs to be done, because otherwise an entry can get obsolete by its own answer or answers of succeeding questions
      final subWorkingElement = _createWorkingElement(
        _entries.getRange(0, i)
      );
      // get whether the question conditions of an entry still matches
      // the current working element
      final questionIsMatching = entry.question.conditions.any((condition) {
        return condition.matches(subWorkingElement);
      });

      // if the conditions of an answer in the history do not match anymore
      if (!questionIsMatching) {
        // remove the answer
        _entries.removeAt(i);
      }
      else {
        // only increment if no element was removed, because the removal will modify the indexes
        i++;
      }
    }
  }


  /// Optionally specify a custom list of entries from which the working element is constructed.

  ProxyElement _createWorkingElement([Iterable<QuestionnaireEntry>? entries]) {
    final changes = (entries ?? _entries)
      .where((entry) => entry.hasValidAnswer)
      .map((entry) => entry.answer!.toTagMap());

    return ProxyElement(_osmElement,
      additionalTags: changes.fold<Map<String, String>>(
        {},
        (tags, newTags) => tags..addAll(newTags)
      )
    );
  }
}


/// A [QuestionnaireEntry] delegates its equality to the underlying question.
/// This means two [QuestionnaireEntry]s are equal if their underlying questions are equal,
/// even though their answers might be different.
/// Therefore instances of this class can be treated more or less as a unique key with an
/// optional answer value.

class QuestionnaireEntry<T extends Answer> {
  QuestionnaireEntry(this.question, [this.answer]);

  final QuestionDefinition question;
  final T? answer;

  bool get hasValidAnswer => answer?.isValid == true;

  @override
  int get hashCode =>
    question.hashCode;

  @override
  bool operator == (other) =>
    identical(this, other) ||
    other is QuestionnaireEntry<T> &&
    runtimeType == other.runtimeType &&
    question == other.question;
}
