import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '/api/overpass_query_api.dart';
import '/models/element_variants/base_element.dart';
import '/models/stop_area/stop_area.dart';
import '/models/stop_area/stop_area_query.dart';
import '/utils/cell_cache.dart';
import '/utils/service_worker.dart';
import '/utils/stream_utils.dart';
import 'element_handler.dart';

/// Handles [Stop] querying and [StopArea] generation by a given view box.
///
/// Queries are done in geographical chunks/cells.
/// Any loaded and generated [StopArea]s are cached.
///
/// Note that the actual size in meters of a cell varies across the globe since the grid is based on latitude and longitude.
/// This is done for simplicity reasons to avoid any sort of projection.
/// More information about this approach can be found here https://en.wikipedia.org/wiki/Discrete_global_grid#Non-hierarchical_grids

mixin StopAreaHandler<M> on ServiceWorker<M> {
  final _stopAreasStreamController = StreamController<StopAreaUpdate>();
  final _loadingCellsStreamController = StreamController<int>();

  final _overpassAPI = OverpassQueryAPI();
  final _stopAreaQuery = StopAreaQuery();

  final _stopAreaCache = CellCache<Set<StopArea>>();

  final _loadingCells = <CellIndex>{};

  /// All stop areas from [stopAreaCache] where elements have been loaded.

  final _loadedStopAreas = <StopArea>{};

  final _loadingStopAreas = <StopArea>{};

  late final loadedStopAreas = UnmodifiableSetView(_loadedStopAreas);

  /// The cell size in degrees.
  /// Some reference values can be found here: https://en.wikipedia.org/wiki/Decimal_degrees

  // This has been reduced due to long loading times in urban areas, see: https://github.com/OPENER-next/OpenStop/issues/293
  final double _cellSize = 0.02;

  /// A MultiStream that returns the number of currently loading cells on initial subscription.
  ///
  /// Streams [StopArea] state updates.

  late final stopAreasStream = _stopAreasStreamController.stream.makeMultiStreamAsync((
    controller,
  ) async {
    for (final stopArea in _stopAreaCache.items.expand((cell) => cell)) {
      final StopAreaState state;
      if (_loadingStopAreas.contains(stopArea)) {
        state = StopAreaState.loading;
      } else if (_loadedStopAreas.contains(stopArea)) {
        if (await stopAreaHasQuestions(stopArea)) {
          state = StopAreaState.incomplete;
        } else {
          state = StopAreaState.complete;
        }
      } else {
        state = StopAreaState.unloaded;
      }
      controller.addSync(StopAreaUpdate(stopArea, state));
    }
  });

  /// A MultiStream that returns the number of currently loading cells on initial subscription.
  ///
  /// Streams the number of loading cells.

  late final loadingCellsStream = _loadingCellsStreamController.stream.makeMultiStream((
    controller,
  ) {
    controller.addSync(_loadingCells.length);
  });

  /// Can be used by other handlers like the [ElementHandler] to change the state of a [StopArea].

  void markStopArea(StopArea stopArea, StopAreaState state) {
    if (state == StopAreaState.complete || state == StopAreaState.incomplete) {
      _loadingStopAreas.remove(stopArea);
      _loadedStopAreas.add(stopArea);
    } else if (state == StopAreaState.loading) {
      _loadingStopAreas.add(stopArea);
      _loadedStopAreas.remove(stopArea);
    } else {
      _loadingStopAreas.remove(stopArea);
      _loadedStopAreas.remove(stopArea);
    }

    _stopAreasStreamController.add(
      StopAreaUpdate(stopArea, state),
    );
  }

  /// Query all [StopArea] in a given bounding box.
  ///
  /// Newly queried [StopArea]s will be added to the [stopAreasStream]
  /// and marked with the initial state [StopAreaState.unloaded].

  Future<void> queryStopAreas(LatLngBounds bounds) async {
    for (final cellIndex in _bboxToCellIndexes(bounds)) {
      // check whether the given index has already been queried and cached
      if (!_stopAreaCache.contains(cellIndex)) {
        // check whether a query is in progress for the given index
        if (!_loadingCells.contains(cellIndex)) {
          _loadingCells.add(cellIndex);
          _loadingCellsStreamController.add(_loadingCells.length);

          // query cell and add cell index to query records
          final southWest = _cellIndexToGeo(cellIndex);
          final northEast = LatLng(southWest.latitude + _cellSize, southWest.longitude + _cellSize);

          try {
            final stopAreas = (await _overpassAPI.query(
              _stopAreaQuery,
              bbox: LatLngBounds(southWest, northEast),
            )).toSet();
            _stopAreaCache.add(cellIndex, stopAreas);

            for (final stopArea in stopAreas) {
              markStopArea(stopArea, StopAreaState.unloaded);
            }
          } catch (error) {
            // TODO: display error.
            debugPrint(error.toString());
          } finally {
            _loadingCells.remove(cellIndex);
            _loadingCellsStreamController.add(_loadingCells.length);
          }
        }
      }
    }
  }

  /// Find [StopArea]s which intersects with the given bounding box.

  Iterable<StopArea> getStopAreasByBounds(LatLngBounds bounds) {
    return _bboxToCellIndexes(bounds)
        .map(_stopAreaCache.get)
        .nonNulls
        .expand(
          (stopAreas) => stopAreas.where(
            (stopArea) => stopArea.isOverlapping(bounds),
          ),
        );
  }

  /// Finds a stop area a given element overlaps with.

  StopArea findCorrespondingStopArea(ProcessedElement element) {
    return _loadedStopAreas.firstWhere(
      (stopArea) => stopArea.isOverlapping(element.geometry.bounds),
      orElse: () => throw StateError(
        'No surrounding stop area found for ${element.type} ${element.id}.',
      ),
    );
  }

  bool stopAreaIsUnloaded(StopArea stopArea) {
    return !_loadingStopAreas.contains(stopArea) && !_loadedStopAreas.contains(stopArea);
  }

  // Should be implemented by the element handler to get the elements
  Future<bool> stopAreaHasQuestions(StopArea stopArea, [Iterable<ProcessedElement>? elements]);

  @override
  void exit() {
    _stopAreasStreamController.close();
    _loadingCellsStreamController.close();
    _overpassAPI.dispose();
    super.exit();
  }

  /// Method to retrieve all cell indexes that cover given bounding box.

  Iterable<CellIndex> _bboxToCellIndexes(LatLngBounds cameraViewBox) sync* {
    final southWestIndex = _geoToCellIndex(cameraViewBox.southWest);
    final northEastIndex = _geoToCellIndex(cameraViewBox.northEast);

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
    final cellIndexX = (shiftedLat / _cellSize).floor();
    final cellIndexY = (shiftedLng / _cellSize).floor();

    return CellIndex(cellIndexX, cellIndexY);
  }

  /// Method to calculate the geographical coordinates of a given cell index.

  LatLng _cellIndexToGeo(CellIndex index) {
    final cellLatitude = index.x * _cellSize - 90;
    final cellLongitude = index.y * _cellSize - 180;
    return LatLng(cellLatitude, cellLongitude);
  }
}

class StopAreaUpdate {
  final StopArea stopArea;
  final StopAreaState state;

  const StopAreaUpdate(this.stopArea, this.state);
}

enum StopAreaState { unloaded, loading, complete, incomplete }
