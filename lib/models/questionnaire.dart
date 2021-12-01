import 'dart:collection';

import 'package:osm_api/osm_api.dart';

import '/models/question.dart';
import '/models/answer.dart';
import '/models/proxy_osm_element.dart';


class Questionnaire {

  Questionnaire({
    required OSMElement osmElement,
    required List<Question> questionCatalog,
  }) :
    _questionCatalog = questionCatalog,
    _osmElement = osmElement
  {
    _updateWorkingElement();
    _addMatchingEntries(afterIndex: -1);
  }

  final List<Question> _questionCatalog;

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


  QuestionnaireEntry? get activeEntry{
    if (_isValidIndex(_activeIndex)) {
      return _entries[_activeIndex];
    }
  }


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


  void update(Answer answer) {
    if (_isValidIndex(_activeIndex)) {
      _entries[_activeIndex] = QuestionnaireEntry(
        _entries[_activeIndex].question,
        answer
      );
      _updateWorkingElement();
      _removeObsoleteEntries();
      _addMatchingEntries();
    }
  }


  bool _isValidIndex(int index) {
    return index >= 0 && _entries.length > index;
  }


  void _updateWorkingElement() {
    final List<Map<String, String>> changes = [];
    _entries.forEach((entry) {
      if (entry.answer != null) {
        changes.add(entry.answer!.toTagMap());
      }
    });

    _workingElement = ProxyOSMElement(
      _osmElement,
      changes: changes
    );
  }


  _addMatchingEntries({ int? afterIndex }) {
    afterIndex ??= _activeIndex;
    // insert questions in reverse so questions that follow next in the catalog
    // also follow next in the questionnaire
    for (final question in _questionCatalog.reversed) {
      final questionMatches = question.conditions.any((condition) {
        return condition.matches(
          workingElement.tags,
          workingElement.type
        );
      });

      if (questionMatches) {
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
      // if the conditions of an answer in the history do not match anymore
      // remove the answer
      final questionMatches = entry.question.conditions.any((condition) {
        return condition.matches(
          workingElement.tags,
          workingElement.type
        );
      });

      if (!questionMatches) {
        _entries.removeAt(i);
      }
    }
  }
}


class QuestionnaireEntry {
  QuestionnaireEntry(this.question, [this.answer]);

  final Question question;
  final Answer? answer;
}