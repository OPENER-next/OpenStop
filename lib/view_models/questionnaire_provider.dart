import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:osm_api/osm_api.dart';

import '/models/questionnaire.dart';
import '/models/proxy_osm_element.dart';
import '/models/answer.dart';
import '/models/question_catalog.dart';


class QuestionnaireProvider extends ChangeNotifier {

  Questionnaire? _qaSelection;

  UniqueKey? _key;


  bool get hasEntries => _qaSelection != null && _qaSelection!.length > 0;


  ProxyOSMElement? get workingElement => _qaSelection?.workingElement;


  int? get length => _qaSelection?.length;


  UnmodifiableListView<QuestionnaireEntry>? get entries => _qaSelection?.entries;


  int? get activeIndex => _qaSelection?.activeIndex;

  QuestionnaireEntry? get activeEntry => _qaSelection?.activeEntry;


  /// An unique identifier for the current questionnaire

  UniqueKey? get key => _key;


  void create(OSMElement osmElement, QuestionCatalog questionCatalog) {
    _qaSelection = Questionnaire(
      osmElement: osmElement,
      questionCatalog: questionCatalog
    );
    _key = UniqueKey();
    notifyListeners();
  }


  void discard() {
    _qaSelection = null;
    _key = null;
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
