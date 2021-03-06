import 'dart:collection';

import 'package:osm_api/osm_api.dart';

import '/models/question_catalog.dart';
import '/models/question.dart';
import '/models/answer.dart';
import '/models/proxy_osm_element.dart';


class Questionnaire {

  Questionnaire({
    required OSMElement osmElement,
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

  final OSMElement _osmElement;

  late ProxyOSMElement _workingElement;

  int _activeIndex = 0;


  ProxyOSMElement get workingElement => _workingElement;


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
      _updateWorkingElement();
      _removeObsoleteEntries();
      _insertMatchingEntries();
    }
  }


  bool _isValidIndex(int index) {
    return index >= 0 && _entries.length > index;
  }


  void _updateWorkingElement() {
    _workingElement = _createWorkingElement(_entries);
  }


  _insertMatchingEntries({ int? afterIndex }) {
    afterIndex ??= _activeIndex;
    // insert questions in reverse so questions that follow next in the catalog
    // also follow next in the questionnaire
    for (final question in _questionCatalog.reversed) {
      // get whether the question conditions matches the current working element
      final questionIsMatching = question.conditions.any((condition) {
        return condition.matches(
          _workingElement.tags,
          _workingElement.type
        );
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
    // only iterate over all elements after the current active index
    for (var i = _entries.length - 1; i > _activeIndex; i--) {
      final entry = _entries[i];
      // create working element from all preceding entries excluding the current entry
      // this needs to be done, because otherwise an entry can get obsolete by its own answer or answers of succeeding questions
      final subWorkingElement = _createWorkingElement(
        _entries.getRange(0, i)
      );
      // get whether the question conditions of an entry still matches
      // the current working element
      final questionIsMatching = entry.question.conditions.any((condition) {
        return condition.matches(
          subWorkingElement.tags,
          subWorkingElement.type
        );
      });

      // if the conditions of an answer in the history do not match anymore
      if (!questionIsMatching) {
        // remove the answer
        _entries.removeAt(i);
      }
    }
  }


  /// Optionally specify a custom list of entries from which the working element is constructed.

  ProxyOSMElement _createWorkingElement(Iterable<QuestionnaireEntry> entries) {
    final changes = entries
      .where((entry) => entry.answer != null)
      .map((entry) => entry.answer!.toTagMap())
      .toList();

    return ProxyOSMElement(
      _osmElement,
      changes: changes
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

  final Question question;
  final T? answer;


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
