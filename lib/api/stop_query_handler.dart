import 'dart:async';
import 'dart:math';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:dio/dio.dart';
import '/models/stop.dart';

/// A class that automatically queries [Stop]s from the database based on a given camera view box.
/// Queries are done in chunks/cells. A query for a specific cell will only be send once to the database.
/// The retrieved [Stop]s will be broadcasted by a [Stream] that can be accessed via the [stops] property.
/// Note that the actual size in meters of a cell varies across the globe since the grid is based on latitude and longitude.
/// This is done for simplicity reasons to avoid any sort of projection.

// possible optimization: batch database requests

class StopQueryHandler {

  final _queryRecorder = StopQueryRecorder();

  /// The cell size in degrees

  final double cellSize;

  /// The relative camera view box extend
  /// The vertical extend is calculated by this value multiplied by the camera view box *height*,
  /// while the horizontal extend is calculated by this value multiplied by the camera view box *width*
  /// The benefit of this method is that the extend automatically scales upon zoom levels

  double viewBoxExtend;

  final _dio = Dio();

  final _queryURL = 'https://overpass-api.de/api/interpreter';

  final _query = '[out:json][timeout:200][bbox];'
                 'relation["public_transport"="stop_area"];'
                 'out tags center;';

  final _results = StreamController<Iterable<Stop>>();

  StopQueryHandler({
    this.cellSize = 0.1,
    this.viewBoxExtend = 0.3
  });


  /// This should be called on camera position changes and will trigger a database query if necessary.
  /// The query results can be accessed via the [stops] property.

  void update(LatLngBounds cameraViewBox) async {
    cameraViewBox = _applyExtend(cameraViewBox);

    var northeastIndex = _geoToCellIndex(cameraViewBox.northeast);
    var southwestIndex = _geoToCellIndex(cameraViewBox.southwest);

    for (var x = southwestIndex.x; x <= northeastIndex.x; x++) {
      for (var y = southwestIndex.y; y <= northeastIndex.y; y++) {
        final cellIndex = Point<int>(x, y);
        // check whether the database has already been queried for the given cell index
        if (!_queryRecorder.contains(cellIndex)) {
          // add cell index to query cache
          _queryRecorder.add(cellIndex);
          // query stops
          _queryStopsInCell(cellIndex).then((response) {
              // add stops to the stream
              _results.add(_queryResponseToStops(response));
            }, onError: (error) {
              print(error);
              // on error remove cache entry so it can/will be re-queried
              _queryRecorder.remove(cellIndex);
            }
          );
        }
      }
    }
  }


  /// The stream that returns a list of newly queried stops.

  Stream<Iterable<Stop>> get stops => _results.stream;


  /// This method calculates the absolute box extend and applies it to the given camera view box

  LatLngBounds _applyExtend(LatLngBounds cameraViewBox) {
    var cameraViewBoxHeight = (cameraViewBox.northeast.latitude - cameraViewBox.southwest.latitude).abs();
    var cameraViewBoxWidth = (cameraViewBox.northeast.longitude - cameraViewBox.southwest.longitude).abs();

    var extend = LatLng(
      cameraViewBoxHeight * this.viewBoxExtend,
      cameraViewBoxWidth * this.viewBoxExtend
    );

    return LatLngBounds(
      southwest: cameraViewBox.southwest - extend,
      northeast: cameraViewBox.northeast + extend
    );
  }


  /// Method to convert the database results to a lazy [Iterable] of [Stop]s.

  Iterable<Stop> _queryResponseToStops(Response<Map<String, dynamic>> response) sync* {
    if (response.data?['elements'] != null) {
      for (final element in response.data!['elements']) {
        yield Stop.fromOverpassJSON(element);
      }
    }
  }


  /// Method to calculate the cell index that contains the given coordinates

  Point<int> _geoToCellIndex(LatLng geoPoint) {
    // transform from [-90, 90] to [0, 180]
    final shiftedLat = geoPoint.latitude + 90;
    // transform from [-180, 180) to [0, 360)
    final shiftedLng = geoPoint.longitude + 180;
    // scale and round to nearest cell index
    final cellIndexX = (shiftedLat / cellSize).floor();
    final cellIndexY = (shiftedLng / cellSize).floor();

    return Point(cellIndexX, cellIndexY);
  }


  /// Method to calculate the geographical coordinates of a given cell index

  LatLng _cellIndexToGeo(Point<int> index) {
    final cellLatitude = index.x * cellSize - 90;
    final cellLongitude = index.y * cellSize - 180;
    return LatLng(cellLatitude, cellLongitude);
  }


  /// Method to query all stops from a specific cell via Overpass API

  Future<Response<Map<String, dynamic>>> _queryStopsInCell(Point<int> cellIndex) {
    final southWest = _cellIndexToGeo(cellIndex);
    final northEast = LatLng(southWest.latitude + cellSize, southWest.longitude + cellSize);

    return _dio.get<Map<String, dynamic>>(_queryURL,
      queryParameters: {
        'data': _query,
        'bbox': '${southWest.longitude},${southWest.latitude},${northEast.longitude},${northEast.latitude}'
      }
    );
  }


  /// A method to cleanup the database connection and stream.
  /// This should be called inside the widgets dispose callback.

  void dispose() {
    _dio.close(force: true);
    _results.close();
  }
}


/// A cache of cell indices that have been used to send a query to the database.
/// This is only used to check wether a query with the given cell index has been made or not,
/// which means there is no data attached to any cell index.

class StopQueryRecorder {
  /// Every cell is identified by an index that can be represented as a 2D point
  /// key = x : value with [Set] of y values

  final Map<int, Set<int>> _queriedCells = {};


  /// Method to remove a given cell index from the cache.

  void remove(Point<int> index) {
    final column = _queriedCells[index.x];
    if (column != null) {
      column.remove(index.y);
      if (column.isEmpty) {
        _queriedCells.remove(index.x);
      }
    }
  }


  /// Method to add a new cell index to the cache.

  void add(Point<int> index) {
    final column = _queriedCells[index.x];
    if (column == null) {
      _queriedCells[index.x] = {index.y};
    }
    else {
      column.add(index.y);
    }
  }


  /// Method to check if the given cell index has already been added.

  bool contains(Point<int> index) {
    final column = _queriedCells[index.x];
    if (column == null) return false;
    return column.contains(index.y);
  }
}