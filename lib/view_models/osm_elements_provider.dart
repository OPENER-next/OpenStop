import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:osm_api/osm_api.dart';
import '/api/osm_element_query_api.dart';
import '/models/stop_area.dart';
import '/commons/geo_utils.dart';

class OSMElementProvider extends ChangeNotifier {

  /// The diameter by which stops should be merged into a single [StopArea]

  final double stopAreaDiameter;

  final _osmElementQueryHandler = OSMElementQueryAPI();

  final _loadingStopAreas = Set<StopArea>();

  final _loadedStopAreas = Map<StopArea, OSMElementBundle>();

  OSMElementProvider({
    required this.stopAreaDiameter
  });


  UnmodifiableSetView<StopArea> get loadingStopAreas
    => UnmodifiableSetView(_loadingStopAreas);


  UnmodifiableMapView<StopArea, OSMElementBundle> get loadedStopAreas
    => UnmodifiableMapView(_loadedStopAreas);


  void loadStopAreaElements(StopArea stopArea) async {
    if (!_loadingStopAreas.contains(stopArea) && !_loadedStopAreas.containsKey(stopArea)) {
      _loadingStopAreas.add(stopArea);
      notifyListeners();
      try {
        final bbox = stopArea.bounds.enlargeByMeters(stopAreaDiameter/2);
        final osmElements = await _osmElementQueryHandler.queryByBBox(bbox);
        _loadedStopAreas[stopArea] = osmElements;
      }
      catch(error) {
        // TODO: display error.
        print(error);
      }
      finally {
        _loadingStopAreas.remove(stopArea);
        notifyListeners();
      }
    }
  }


  @override
  void dispose() {
    super.dispose();
    _osmElementQueryHandler.dispose();
  }
}