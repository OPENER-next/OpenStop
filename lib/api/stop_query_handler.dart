import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '/models/stop.dart';

/// A class that automatically queries [Stop]s via the Overpass API based on a given camera view box.
/// Queries are done in chunks/cells. A query for a specific cell will only be send once to the Server.
/// The retrieved [Stop]s will be broadcasted by a [Stream] that can be accessed via the [stops] property.
/// Note that the actual size in meters of a cell varies across the globe since the grid is based on latitude and longitude.
/// This is done for simplicity reasons to avoid any sort of projection.
/// More information about this approach can be found here https://en.wikipedia.org/wiki/Discrete_global_grid#Non-hierarchical_grids

// possible optimization: batch database requests

class StopQueryHandler {

  static const _overpassAPIServers = [
    'https://overpass.kumi.systems/api/interpreter',
    'https://overpass-api.de/api/interpreter',
  ];

  static const _query =
    '[out:json][timeout:1000][bbox];'
    'nwr["public_transport"="platform"];'
    'out tags center;';

  /// The cell size in degrees.
  /// Some reference values can be found here: https://en.wikipedia.org/wiki/Decimal_degrees

  final double cellSize;

  /// The relative camera view box extend.
  /// The vertical extend is calculated by this value multiplied by the camera view box *height*,
  /// while the horizontal extend is calculated by this value multiplied by the camera view box *width*.
  /// The benefit of this method is that the extend automatically scales upon zoom levels.

  double viewBoxExtend;

  final _queryRecorder = StopQueryRecorder();

  final _dio = Dio();

  final _random = Random();

  LatLngBounds? _lastCameraViewBox;

  final _results = StreamController<Iterable<Stop>>();

  final _pendingQueryCount = ValueNotifier<int>(0);

  StopQueryHandler({
    this.cellSize = 0.1,
    this.viewBoxExtend = 0.3
  });


  /// This should be called on camera position changes and will trigger a database query if necessary.
  /// The query results can be accessed via the [stops] property.

  void update(LatLngBounds cameraViewBox) {
    _lastCameraViewBox = cameraViewBox;
    _update();
  }


  /// A [Stream] that returns a list of newly queried stops.

  Stream<Iterable<Stop>> get stops => _results.stream;


  /// A [ValueNotifier] that indicate whether the loading of stops is in progress or not.

  ValueNotifier<int> get pendingQueryCount => _pendingQueryCount;


  void _update() {
    final cameraViewBox = _applyExtend(_lastCameraViewBox!);

    for (final cellIndex in _bboxToCellIndexes(cameraViewBox)) {
      // check whether the database has already been queried for the given cell index
      if (!_queryRecorder.contains(cellIndex)) {
        // add cell index to query cache
        _queryRecorder.add(cellIndex);
        // query stops
        _queryStopsInCell(cellIndex)
          .then(_handleQuerySuccess)
          .catchError((error) {
            // remove cache entry so it can/will be re-queried
            _queryRecorder.remove(cellIndex);
            _handleQueryError(error);
          })
          .whenComplete(_handleQueryComplete);
      }
    }
  }


  void _handleQuerySuccess(Response<Map<String, dynamic>> response) {
    // add stops to the stream
    _results.add(_queryResponseToStops(response));
  }


  void _handleQueryError(error) {
    print(error);
    // recall update function with the latest cameraViewBox after 1 second
    Future.delayed(Duration(seconds: 1), () => _update());
  }


  void _handleQueryComplete() {
    // decrease query counter
    _pendingQueryCount.value--;
  }


  /// This method calculates the absolute box extend and applies it to the given camera view box

  LatLngBounds _applyExtend(LatLngBounds cameraViewBox) {
    var cameraViewBoxHeight = (cameraViewBox.northEast!.latitude - cameraViewBox.southWest!.latitude).abs();
    var cameraViewBoxWidth = (cameraViewBox.northEast!.longitude - cameraViewBox.southWest!.longitude).abs();

    // calculate relative extend
    var extend = LatLng(
      cameraViewBoxHeight * this.viewBoxExtend,
      cameraViewBoxWidth * this.viewBoxExtend
    );

    return LatLngBounds(
      LatLng(
        cameraViewBox.south - extend.latitude,
        cameraViewBox.west - extend.longitude
      ),
      LatLng(
        cameraViewBox.north + extend.latitude,
        cameraViewBox.east + extend.longitude
      )
    );
  }


  /// Method to convert the Overpass API response to a lazy [Iterable] of [Stop]s.

  Iterable<Stop> _queryResponseToStops(Response<Map<String, dynamic>> response) sync* {
    if (response.data?['elements'] != null) {
      for (final element in response.data!['elements']) {
        yield Stop.fromOverpassJSON(element);
      }
    }
  }


  /// Method to retrieve all cell indexes that cover given bounding box.

  Iterable<Point<int>> _bboxToCellIndexes(LatLngBounds cameraViewBox) sync* {
    final southWestIndex = _geoToCellIndex(cameraViewBox.southWest!);
    final northEastIndex = _geoToCellIndex(cameraViewBox.northEast!);

    for (var x = southWestIndex.x; x <= northEastIndex.x; x++) {
      for (var y = southWestIndex.y; y <= northEastIndex.y; y++) {
        yield Point<int>(x, y);
      }
    }
  }


  /// Method to calculate the cell index that contains the given coordinates.

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


  /// Method to calculate the geographical coordinates of a given cell index.

  LatLng _cellIndexToGeo(Point<int> index) {
    final cellLatitude = index.x * cellSize - 90;
    final cellLongitude = index.y * cellSize - 180;
    return LatLng(cellLatitude, cellLongitude);
  }


  /// Method to query all stops from a specific cell via Overpass API.

  Future<Response<Map<String, dynamic>>> _queryStopsInCell(Point<int> cellIndex) {
    final southWest = _cellIndexToGeo(cellIndex);
    final northEast = LatLng(southWest.latitude + cellSize, southWest.longitude + cellSize);
    // get random url from server list
    final url = _overpassAPIServers[_random.nextInt(_overpassAPIServers.length)];

    _pendingQueryCount.value++;

    return _dio.get<Map<String, dynamic>>(url,
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
    _pendingQueryCount.dispose();
  }
}


/// A cache of cell indices that have been used to send a query to an Overpass API instance.
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