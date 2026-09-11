import 'dart:async';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';

import '/models/element_variants/base_element.dart';
import '/models/stop_area/stop_area.dart';
import '/utils/service_worker.dart';
import '/utils/stream_utils.dart';
import '../stop_area_api.dart';
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
  final _h3Resolution = 4;

  final _stopAreaApi = CachedStopAreaAPI();

  final _stopAreasStreamController = StreamController<StopAreaUpdate>();
  final _loadingCellsStreamController = StreamController<int>();

  final _stopAreaCache = <BigInt, Set<StopArea>>{};

  final _loadingCells = <BigInt>{};

  /// All stop areas from [stopAreaCache] where elements have been loaded.

  final _loadedStopAreas = <StopArea>{};

  final _loadingStopAreas = <StopArea>{};

  late final loadedStopAreas = UnmodifiableSetView(_loadedStopAreas);

  /// A MultiStream that returns the number of currently loading cells on initial subscription.
  ///
  /// Streams [StopArea] state updates.

  late final stopAreasStream = _stopAreasStreamController.stream.makeMultiStreamAsync((
    controller,
  ) async {
    for (final stopArea in _stopAreaCache.values.expand((cell) => cell)) {
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
    for (final cellId in bounds.toH3Ids(resolution: _h3Resolution)) {
      // check whether the given index has already been queried and cached
      // or whether a query is in progress for the given index
      if (_stopAreaCache.containsKey(cellId) || _loadingCells.contains(cellId)) {
        continue;
      }
      _loadingCells.add(cellId);
      _loadingCellsStreamController.add(_loadingCells.length);

      try {
        final stopAreas = await _stopAreaApi.queryByH3Id(cellId).toSet();
        _stopAreaCache[cellId] = stopAreas;

        for (final stopArea in stopAreas) {
          markStopArea(stopArea, StopAreaState.unloaded);
        }
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
        // assume empty cell on 404 error and cache empty Set in memory
        _stopAreaCache[cellId] = {};
      } catch (error) {
        // TODO: display error.
        debugPrint(error.toString());
      } finally {
        _loadingCells.remove(cellId);
        _loadingCellsStreamController.add(_loadingCells.length);
      }
    }
  }

  /// Find [StopArea]s which intersects with the given bounding box.

  Iterable<StopArea> getStopAreasByBounds(LatLngBounds bounds) {
    return bounds
        .toH3Ids(resolution: _h3Resolution)
        .map((id) => _stopAreaCache[id])
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
    _stopAreaApi.dispose();
    super.exit();
  }
}

class StopAreaUpdate {
  final StopArea stopArea;
  final StopAreaState state;

  const StopAreaUpdate(this.stopArea, this.state);
}

enum StopAreaState { unloaded, loading, complete, incomplete }
