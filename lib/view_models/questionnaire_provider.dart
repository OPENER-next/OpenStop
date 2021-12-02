import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:opener_next/models/questionnaire.dart';
import 'package:osm_api/osm_api.dart';

import '/models/proxy_osm_element.dart';
import '/models/answer.dart';
import '/models/question.dart';


class QuestionnaireProvider extends ChangeNotifier {

  Questionnaire? _qaSelection;


  bool get hasEntries => _qaSelection != null && _qaSelection!.length > 0;


  ProxyOSMElement? get workingElement => _qaSelection?.workingElement;


  int? get length => _qaSelection?.length;


  UnmodifiableListView<QuestionnaireEntry>? get entries => _qaSelection?.entries;


  int? get activeIndex => _qaSelection?.activeIndex;

  QuestionnaireEntry? get activeEntry => _qaSelection?.activeEntry;


  void create(OSMElement osmElement, List<Question> questionCatalog) {
    _qaSelection = Questionnaire(
      osmElement: osmElement,
      questionCatalog: questionCatalog
    );
    notifyListeners();
  }


  void discard() {
    _qaSelection = null;
    notifyListeners();
  }


  void update(Answer? answer) {
    if (_qaSelection != null) {
      _qaSelection!.update(answer);
      notifyListeners();
    }
  }


  bool previous() {
    if (_qaSelection?.previous() == true) {
      notifyListeners();
      return true;
    }
    return false;
  }


  bool next() {
    if (_qaSelection?.next() == true) {
      notifyListeners();
      return true;
    }
    return false;
  }
}