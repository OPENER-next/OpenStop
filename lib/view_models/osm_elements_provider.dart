import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:osm_api/osm_api.dart';
import '/api/osm_element_query_api.dart';
import '/models/stop_area.dart';

class OSMElementProvider extends ChangeNotifier {

  final _osmElementQueryHandler = OSMElementQueryAPI();

  final _loadingStopAreas = <StopArea>{};

  final _loadedStopAreas = <StopArea, OSMElementBundle>{};

  OSMElementProvider();


  UnmodifiableSetView<StopArea> get loadingStopAreas
    => UnmodifiableSetView(_loadingStopAreas);


  UnmodifiableMapView<StopArea, OSMElementBundle> get loadedStopAreas
    => UnmodifiableMapView(_loadedStopAreas);


  Set<OSMElement> get loadedOsmElements {
    // use set to remove duplicates
    return Set.of(_loadedStopAreas.values.expand<OSMElement>(
      (bundle) => bundle.elements
    ));
  }


  void loadStopAreaElements(StopArea stopArea) async {
    if (!_loadingStopAreas.contains(stopArea) && !_loadedStopAreas.containsKey(stopArea)) {
      _loadingStopAreas.add(stopArea);
      notifyListeners();
      try {
        final bbox = stopArea.bounds;
        final osmElements = await _osmElementQueryHandler.queryByBBox(bbox);
        _loadedStopAreas[stopArea] = osmElements;
      }
      catch(error) {
        // TODO: display error.
        debugPrint(error.toString());
      }
      finally {
        _loadingStopAreas.remove(stopArea);
        notifyListeners();
      }
    }
  }


  @override
  void dispose() {
    _osmElementQueryHandler.dispose();
    super.dispose();
  }
}
