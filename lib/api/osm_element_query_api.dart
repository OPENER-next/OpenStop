import 'package:flutter_map/flutter_map.dart';
import 'package:osm_api/osm_api.dart';


/// This class exposes API calls for querying [OSMElement]s via the OSM API.

class OSMElementQueryAPI {
  final OSMAPI _osmApi;

  OSMElementQueryAPI({
    String endPoint = 'https://www.openstreetmap.org/api/0.6',
  }) :
    _osmApi = OSMAPI(
      baseUrl: endPoint,
    );


  /// Method to query all OSM elements from a specific bbox via OSM API.
  /// This method will throw [OSMAPI] connection errors.

  Future<OSMElementBundle> queryByBBox(LatLngBounds bbox) {
    return _osmApi.getElementsByBoundingBox(
      BoundingBox(
        bbox.west, bbox.south, bbox.east, bbox.north
      )
    );
  }


  /// A method to terminate the api client and cleanup any open connections.
  /// This should be called inside the widgets dispose callback.

  dispose() {
    _osmApi.dispose();
  }
}
