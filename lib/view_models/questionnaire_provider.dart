import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:osm_api/osm_api.dart';
import 'package:provider/provider.dart';

import '/api/osm_element_upload_api.dart';
import '/view_models/osm_elements_provider.dart';
import '/models/authenticated_user.dart';
import '/models/map_feature_collection.dart';
import '/models/questionnaire.dart';
import '/models/proxy_osm_element.dart';
import '/models/answer.dart';
import '/models/question_catalog.dart';


class QuestionnaireProvider extends ChangeNotifier {

  Questionnaire? _qaSelection;


  bool get hasEntries => _qaSelection != null && _qaSelection!.length > 0;


  ProxyOSMElement? get workingElement => _qaSelection?.workingElement;


  int? get length => _qaSelection?.length;


  UnmodifiableListView<QuestionnaireEntry>? get entries => _qaSelection?.entries;


  int? get activeIndex => _qaSelection?.activeIndex;

  QuestionnaireEntry? get activeEntry => _qaSelection?.activeEntry;


  /// An unique identifier for the current questionnaire

  ValueKey<Questionnaire?> get key => ValueKey(_qaSelection);


  void create(OSMElement osmElement, QuestionCatalog questionCatalog) {
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


  bool jumpTo(int index) {
    if (_qaSelection?.jumpTo(index) == true) {
      notifyListeners();
      return true;
    }
    return false;
  }


  /// Upload the changes made by this questionnaire with the given authenticated user.

  Future<void> upload(BuildContext context, AuthenticatedUser authenticatedUser) async {
    if (_qaSelection == null) {
      return;
    }

    final mapFeatureCollection = context.read<MapFeatureCollection>();
    final localization = Localizations.localeOf(context);
    final osmElementProvider = context.read<OSMElementProvider>();

    // find the corresponding stop area
    final relatedStopArea = osmElementProvider.osmElementsMap.entries.firstWhere(
      (entry) => entry.value.elements.any(
        (element) => _qaSelection!.workingElement.isProxiedElement(element)
      )).key;

    final uploadApi = OSMElementUploadAPI(
      mapFeatureCollection: mapFeatureCollection,
      authenticatedUser: authenticatedUser,
      changesetLocale: localization.languageCode
    );

    final Questionnaire tmpQaSelection = _qaSelection!;
    // close the current questionnaire
    discard();

    await uploadApi.updateOsmElement(
      relatedStopArea, tmpQaSelection.workingElement.apply()
    );
  }
}
