part of 'base_element.dart';

/// Concrete implementation of [ProcessedElement] for OSM relations.
/// See [ProcessedElement] for details.
///
/// The geometry calculation requires adding all children/members in beforehand via `addChild`.

class ProcessedRelation extends ProcessedElement<osmapi.OSMRelation, GeographicGeometry>
    with ChildElement, ParentElement {
  ProcessedRelation(super.element);

  /// Do not modify any of the members.

  Iterable<osmapi.OSMMember> get members => Iterable.castFrom(_osmElement.members);

  @override
  UnmodifiableSetView<ProcessedRelation> get parents =>
      UnmodifiableSetView(_parents.cast<ProcessedRelation>());

  @override
  void addParent(ProcessedRelation element) => super.addParent(element);

  @override
  void removeParent(ProcessedRelation element) => super.removeParent(element);

  /// All members that this relation references must be added before calling this via `addChild`.
  ///
  /// Note: Other relations that this relation might contain are currently ignored.
  ///
  /// For any relation other than of type "multipolygon" this will build a
  /// [GeographicCollection] which may not contain all elements of the relation,
  /// because its data may not be fetched entirely.
  /// This happens for example for large relations like the boundary of germany.
  ///
  /// This method throws for unresolvable relations:
  /// - for multipolygons when a child is missing
  /// - for other relations when all children are missing

  @override
  void calcGeometry() {
    if (tags['type'] == 'multipolygon') {
      _geometry = _fromMultipolygonRelation();
    } else if (children.isNotEmpty) {
      _geometry = GeographicCollection([
        for (final child in children) child.geometry,
      ]);
    } else {
      throw Exception(
        'Geometry calculation failed because no children of relation $id have been loaded.',
      );
    }
  }

  /// This algorithm is inspired by https://wiki.openstreetmap.org/wiki/Relation:multipolygon/Algorithm
  GeographicGeometry _fromMultipolygonRelation() {
    // assert that the provided ways are exactly the ones referenced by the relation.
    assert(
      _osmElement.members
          .where((member) => member.type == osmapi.OSMElementType.way)
          .every(
            (member) => _children.any(
              (element) => element is ProcessedWay && element.id == member.ref,
            ),
          ),
      'OSM relation $id referenced ways that cannot be found in the provided way data set.',
    );

    final outerClosedPolylines = <GeographicPolyline>[];
    final innerClosedPolylines = <GeographicPolyline>[];

    // Only extract ids where role is "inner", we will later assume that all ways/ids not extracted here have "outer".
    // This means that if a wrong role or nothing is set we will always fallback to "outer".
    // This assumption should also lead to a little performance boost.
    final innerWayIds = <int>{};
    for (final member in _osmElement.members) {
      if (member.role == 'inner' && member.type == osmapi.OSMElementType.way) {
        innerWayIds.add(member.ref);
      }
    }

    // first step: ring grouping

    final nodePositionLookUp = <int, LatLng>{};

    var wayList = _children.whereType<ProcessedWay>().map<osmapi.OSMWay>((way) {
      for (final node in way.children) {
        nodePositionLookUp[node.id] = node.geometry.center;
      }
      return way._osmElement;
    }).toList();

    while (wayList.isNotEmpty) {
      final workingWay = wayList.removeLast();

      final wayNodePool = _extractRingFromWays(wayList, workingWay);

      final accumulatedCoordinates = wayNodePool.nodeIds.map((id) {
        try {
          return nodePositionLookUp[id]!;
        } on TypeError {
          throw StateError('OSM node with id $id not found in the provided node data set.');
        }
      }).toList();

      final closedPolyline = GeographicPolyline(accumulatedCoordinates);
      // add polyline to the appropriate polyline set
      if (innerWayIds.contains(workingWay.id)) {
        innerClosedPolylines.add(closedPolyline);
      } else {
        outerClosedPolylines.add(closedPolyline);
      }

      wayList = wayNodePool.remainingWays;
    }

    // second step: polygon grouping

    final polygons = <GeographicPolygon>[];

    // as long as there are outer polylines loop
    while (outerClosedPolylines.isNotEmpty) {
      // find first most inner polyline from outer polylines
      var currentPolygon = GeographicPolygon(outerShape: outerClosedPolylines.first);
      var outerPolylineIndex = 0;
      for (var i = 1; i < outerClosedPolylines.length; i++) {
        final polygon = GeographicPolygon(outerShape: outerClosedPolylines[i]);
        if (currentPolygon.enclosesPolygon(polygon)) {
          currentPolygon = polygon;
          outerPolylineIndex = i;
        }
      }
      // remove the current outer polyline from the collection
      outerClosedPolylines.removeAt(outerPolylineIndex);

      // find all inner polylines within the current outer polyline
      // remove them from the inner polyline collection and assign them to the current polygon
      for (var i = innerClosedPolylines.length - 1; i >= 0; i--) {
        if (currentPolygon.enclosesPolyline(innerClosedPolylines[i])) {
          currentPolygon.innerShapes.add(
            innerClosedPolylines.removeAt(i),
          );
        }
      }

      polygons.add(currentPolygon);
    }

    if (polygons.length > 1) {
      return GeographicMultipolygon(polygons);
    }
    return polygons.single;
  }

  /// Extracts a ring (polygon) from the given ways starting with the initial way.
  /// This function connects ways that share an equal end/start point till a ring is formed.
  /// For cases where multiple ways connect at the same node this algorithm traverses all possible way-concatenations till a valid ring is found.
  /// It does this by creating a history of possible concatenations and backtracks if it couldn't find a valid ring.
  /// This is basically recursive but implemented in a non recursive way to mitigate any stack overflow.
  /// Throws an error if no ring could be built from the given ways

  _WayNodeIdPool _extractRingFromWays(List<osmapi.OSMWay> wayList, osmapi.OSMWay initialWay) {
    // this is used to keep a history which is required for backtracking the algorithm
    final workingWayHistory = ListQueue<Iterator<_WayNodeIdPool>>();
    // add new way as initial history entry
    workingWayHistory.add(
      [_WayNodeIdPool(wayList, initialWay.nodeIds)].iterator,
    );

    while (workingWayHistory.isNotEmpty) {
      while (workingWayHistory.last.moveNext()) {
        final lastEntry = workingWayHistory.last.current;
        final lastNodeId = lastEntry.nodeIds.last;
        final firstNodeId = workingWayHistory.first.current.nodeIds.first;

        // if ring is closed
        // TODO: Maybe add further checks/validation, for example if the ring is self-intersecting
        if (firstNodeId == lastNodeId) {
          // traverse the history and accumulate all nodes into a single iterable
          final nodes = workingWayHistory
              .map((historyEntry) => historyEntry.current.nodeIds)
              .expand((nodeIdList) => nodeIdList);

          return _WayNodeIdPool(lastEntry.remainingWays, nodes);
        }
        // take the current ring's end node id and find any connecting ways
        final potentialConnectingWays = _getConnectingWays(lastEntry.remainingWays, lastNodeId);
        // add all node ids of potential connecting ways to the history
        workingWayHistory.add(potentialConnectingWays.iterator);
      }
      workingWayHistory.removeLast();
    }

    throw StateError('Ring extraction failed for OSM multipolygon relation.');
  }

  /// Returns a lazy iterable with a list of node ids from each way that connects to the given node id.
  /// The node list order is already adjusted so that the first node will always connect to the given [nodeId].
  /// Note: This means that the first original node is not included since it's equal to the given [nodeId].

  Iterable<_WayNodeIdPool> _getConnectingWays(List<osmapi.OSMWay> wayList, int nodeId) sync* {
    // look for unassigned ways that start or end with the given node id
    for (var i = 0; i < wayList.length; i++) {
      final way = wayList[i];
      // reverse node list depending on the node where the way connects
      // also ignore/filter the first node id since it's equal to the given [nodeId]
      if (way.nodeIds.last == nodeId) {
        // create a copy of the way list with all ways except the current way
        final subWayList = List.of(wayList)..removeAt(i);
        yield _WayNodeIdPool(
          subWayList,
          way.nodeIds.reversed.skip(1),
        );
      } else if (way.nodeIds.first == nodeId) {
        // create a copy of the way list with all ways except the current way
        final subWayList = List.of(wayList)..removeAt(i);
        yield _WayNodeIdPool(
          subWayList,
          way.nodeIds.skip(1),
        );
      }
    }
  }
}

class _WayNodeIdPool {
  final List<osmapi.OSMWay> remainingWays;
  final Iterable<int> nodeIds;

  _WayNodeIdPool(this.remainingWays, this.nodeIds);
}
