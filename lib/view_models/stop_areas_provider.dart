import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '/helpers/cell_cache.dart';
import '/utils/stop_unifier.dart';
import '/models/stop_area.dart';
import '/api/stop_query_api.dart';


/// A class that automatically queries [StopArea]s via the Overpass API based on a given camera view box.
/// Queries are done in chunks/cells. A query for a specific cell will only be send once to the Server.
/// The retrieved [StopArea]s will be cached and can be accessed via the [stopAreas] property.
/// Note that the actual size in meters of a cell varies across the globe since the grid is based on latitude and longitude.
/// This is done for simplicity reasons to avoid any sort of projection.
/// More information about this approach can be found here https://en.wikipedia.org/wiki/Discrete_global_grid#Non-hierarchical_grids

// possible optimization: batch database requests

class StopAreasProvider extends ChangeNotifier {

  /// The radius by which stops should be merged into a single [StopArea]

  final double stopAreaRadius;


  /// The cell size in degrees.
  /// Some reference values can be found here: https://en.wikipedia.org/wiki/Decimal_degrees

  final double cellSize;

  /// The relative camera view box extend.
  /// The vertical extend is calculated by this value multiplied by the camera view box *height*,
  /// while the horizontal extend is calculated by this value multiplied by the camera view box *width*.
  /// The benefit of this method is that the extend automatically scales upon zoom levels.

  double viewBoxExtend;

  /// Cache all successfully queried [StopArea]s.

  final _stopAreaCache = CellCache<Set<StopArea>>();

  final _stopAPI = StopQueryAPI();

  final _queryRecords = <CellIndex>{};

  final _isLoading = ValueNotifier(false);

  StopAreasProvider({
    this.stopAreaRadius = 50.0,
    this.cellSize = 0.1,
    this.viewBoxExtend = 0.3
  });


  /// All currently queried [StopArea]s.
  /// Listeners will be notified whenever this property changes.

  Iterable<StopArea> get stopAreas {
    return _stopAreaCache.items.expand((stopAreas) => stopAreas);
  }


  /// Whether there are any open/ongoing requests.

  ValueNotifier<bool> get isLoading => _isLoading;


  /// This should be called on camera position changes and will trigger a database query if necessary.
  /// The query results can be accessed via the [stopAreas] property.

  void loadStopAreas(LatLngBounds cameraViewBox) async {
    cameraViewBox = _applyExtend(cameraViewBox);
    for (final cellIndex in _bboxToCellIndexes(cameraViewBox)) {
      // check whether the given index has already been queried and cached
      if (!_stopAreaCache.contains(cellIndex)) {
        // check whether a query is in progress for the given index
        if (!_queryRecords.contains(cellIndex)) {
          _queryRecords.add(cellIndex);
          _isLoading.value = _queryRecords.isNotEmpty;

          // query cell and add cell index to query records
          final southWest = _cellIndexToGeo(cellIndex);
          final northEast = LatLng(southWest.latitude + cellSize, southWest.longitude + cellSize);

          try {
            final stops = await _stopAPI.queryByBBox(southWest, northEast);
            final stopAreas = Set.unmodifiable(
              unifyStops(stops, stopAreaRadius)
            );
            _stopAreaCache.add(cellIndex, stopAreas);
            notifyListeners();
          }
          catch(error) {
            // TODO: display error.
            debugPrint(error.toString());
          }
          finally {
            _queryRecords.remove(cellIndex);
            _isLoading.value = _queryRecords.isNotEmpty;
          }
        }
      }
    }
  }


  /// Find a stop area that encloses the given location.

  StopArea? getStopAreaByPosition(LatLng position) {
    const distance = Distance();
    // construct a bounding box of arbitrary size to get close neighboring cells
    final bbox = LatLngBounds(
      distance.offset(position, stopAreaRadius * 2, 45),
      distance.offset(position, stopAreaRadius * 2, 225)
    );
    final closeCellIndexes = _bboxToCellIndexes(bbox);

    for (final cellIndex in closeCellIndexes) {
      for (final stopArea in _stopAreaCache.get(cellIndex) ?? {}) {
        if (stopArea.isPointInside(position)) {
          return stopArea;
        }
      }
    }

    return null;
  }


  /// This method calculates the absolute box extend and applies it to the given camera view box

  LatLngBounds _applyExtend(LatLngBounds cameraViewBox) {
    final cameraViewBoxHeight = (cameraViewBox.northEast!.latitude - cameraViewBox.southWest!.latitude).abs();
    final cameraViewBoxWidth = (cameraViewBox.northEast!.longitude - cameraViewBox.southWest!.longitude).abs();

    // calculate relative extend
    final extend = LatLng(
      cameraViewBoxHeight * viewBoxExtend,
      cameraViewBoxWidth * viewBoxExtend
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


  /// Method to retrieve all cell indexes that cover given bounding box.

  Iterable<CellIndex> _bboxToCellIndexes(LatLngBounds cameraViewBox) sync* {
    final southWestIndex = _geoToCellIndex(cameraViewBox.southWest!);
    final northEastIndex = _geoToCellIndex(cameraViewBox.northEast!);

    for (var x = southWestIndex.x; x <= northEastIndex.x; x++) {
      for (var y = southWestIndex.y; y <= northEastIndex.y; y++) {
        yield CellIndex(x, y);
      }
    }
  }


  /// Method to calculate the cell index that contains the given coordinates.

  CellIndex _geoToCellIndex(LatLng geoPoint) {
    // transform from [-90, 90] to [0, 180]
    final shiftedLat = geoPoint.latitude + 90;
    // transform from [-180, 180) to [0, 360)
    final shiftedLng = geoPoint.longitude + 180;
    // scale and round to nearest cell index
    final cellIndexX = (shiftedLat / cellSize).floor();
    final cellIndexY = (shiftedLng / cellSize).floor();

    return CellIndex(cellIndexX, cellIndexY);
  }


  /// Method to calculate the geographical coordinates of a given cell index.

  LatLng _cellIndexToGeo(CellIndex index) {
    final cellLatitude = index.x * cellSize - 90;
    final cellLongitude = index.y * cellSize - 180;
    return LatLng(cellLatitude, cellLongitude);
  }


  @override
  void dispose() {
    _stopAPI.dispose();
    _isLoading.dispose();
    super.dispose();
  }
}
