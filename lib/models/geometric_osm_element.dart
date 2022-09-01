
import 'dart:collection';

import 'package:latlong2/latlong.dart';
import 'package:osm_api/osm_api.dart';

import '/utils/osm_tag_area_resolver.dart';
import 'geographic_geometries.dart';

/// A class for creating a geographic element from a given osm element.
/// The equality of a [GeometricOSMElement] is solely determined by the OSM element id and type.

class GeometricOSMElement<T extends OSMElement, G extends GeographicGeometry> {
  final T osmElement;
  final G geometry;

  const GeometricOSMElement({
    required this.osmElement,
    required this.geometry
  });


  /// Create a [GeometricOSMElement] from an osm element and a given bundle of sub osm elements.

  static GeometricOSMElement generateFromOSMElement(OSMElement osmElement, OSMElementBundle elementBundle) {
    switch(osmElement.type) {
      case OSMElementType.node:
        return GeometricOSMElement.generateFromOSMNode(
          osmNode: osmElement as OSMNode
        );
      case OSMElementType.way:
        return GeometricOSMElement.generateFromOSMWay(
          osmWay: osmElement as OSMWay,
          osmNodes: elementBundle.getNodesFromWay(osmElement),
        );
      case OSMElementType.relation:
        return GeometricOSMElement.generateFromOSMRelation(
          osmRelation: osmElement as OSMRelation,
          osmWays: elementBundle.getWaysFromRelation(osmElement),
          osmNodes: elementBundle.nodes
        );
    }
  }

  /// Creates a [GeometricOSMElement] from a single [OSMNode].

  static GeometricOSMElement<OSMNode, GeographicPoint> generateFromOSMNode({
    required OSMNode osmNode,
  }) {
    final geometry = GeographicPoint(
      LatLng(osmNode.lat, osmNode.lon)
    );

    return GeometricOSMElement(
      osmElement: osmNode,
      geometry: geometry
    );
  }

  /// Creates a [GeometricOSMElement] from a single [OSMWay].
  /// The [osmNodes] parameter should contain exactly the node elements that this way references.

  static GeometricOSMElement<OSMWay, GeographicGeometry> generateFromOSMWay({
    required OSMWay osmWay,
    required Iterable<OSMNode> osmNodes
  }) {
    // assert that the provided nodes are exactly the ones referenced by the way.
    assert(
      osmWay.nodeIds.every((nodeId) => osmNodes.any((node) => node.id == nodeId)),
      'OSM way references nodes that cannot be found in the provided node data set.'
    );
    assert(
      osmWay.nodeIds.length == osmNodes.length,
      'OSM way has node references that differ from the provided node data set.'
    );

    final geometry = GeographicPolyline(
      osmNodes.map((node) => LatLng(node.lat, node.lon)).toList()
    );

    if (osmWay.isClosed && isArea(osmWay.tags)) {
      return GeometricOSMElement<OSMWay, GeographicPolygon>(
        osmElement: osmWay,
        geometry: GeographicPolygon(
          outerShape: geometry
        )
      );
    }
    else {
      return GeometricOSMElement<OSMWay, GeographicPolyline>(
        osmElement: osmWay,
        geometry: geometry
      );
    }
  }

  /// Creates a [GeometricOSMElement] from a single [OSMRelation].
  /// The [osmNodes] and [osmWays] parameter should contain all elements that this relation references.
  /// Note: Other relations that this relation might contain are currently ignored.

  static GeometricOSMElement<OSMRelation, GeographicGeometry> generateFromOSMRelation({
    required OSMRelation osmRelation,
    required Iterable<OSMNode> osmNodes,
    required Iterable<OSMWay> osmWays
  }) {
    if (osmRelation.tags['type'] == 'multipolygon') {
      return _fromMultipolygonRelation(
        osmRelation: osmRelation,
        osmNodes: osmNodes,
        osmWays: osmWays
      );
    }
    else {
      // TODO: handle this case properly
      throw 'Unknown type';
      // just calculate a single node based on all nodes above?
      // or show create all elements that are part of this relation?
      // ignore none multipolygons because their data is most likely not fetched entirely. For example a relation like germany
    }
  }


  /// This algorithm is inspired by https://wiki.openstreetmap.org/wiki/Relation:multipolygon/Algorithm

  static GeometricOSMElement<OSMRelation, GeographicGeometry> _fromMultipolygonRelation({
    required OSMRelation osmRelation,
    required Iterable<OSMNode> osmNodes,
    required Iterable<OSMWay> osmWays
  }) {
    final List<GeographicPolyline> outerClosedPolylines = [];
    final List<GeographicPolyline> innerClosedPolylines = [];

    // Only extract ids where role is "inner", we will later assume that all ways/ids not extracted here have "outer".
    // This means that if a wrong role or nothing is set we will always fallback to "outer".
    // This assumption should also lead to a little performance boost.
    final Set<int> innerWayIds = {};
    for (final member in osmRelation.members) {
      if (member.role == 'inner' && member.type == OSMElementType.way) {
        innerWayIds.add(member.ref);
      }
    }

    // first step: ring grouping

    final nodeList = osmNodes.toList();

    // assert that the provided ways are exactly the ones referenced by the relation.
    assert(
      osmRelation.members
        .where((member) => member.type == OSMElementType.way)
        .every((member) => osmWays.any((way) => way.id == member.ref)),
      'OSM relation references ways that cannot be found in the provided way data set.'
    );
    assert(
      osmRelation.members
        .where((member) => member.type == OSMElementType.way)
        .length == osmWays.length,
      'OSM relation has way references that differ from the provided way data set.'
    );
    var wayList = osmWays.toList();

    while (wayList.isNotEmpty) {
      final workingWay = wayList.removeLast();

      final wayNodePool = _extractRingFromWays(wayList, workingWay);

      final accumulatedCoordinates = wayNodePool.nodeIds.map((id) {
        try {
          // find node object by id
          final node = nodeList.firstWhere((node) => node.id == id);
          // convert node object to LatLng
          return LatLng(node.lat, node.lon);
        }
        on StateError {
          throw StateError('OSM relation member of type node with id $id not found in the provided node data set.');
        }
      }).toList();

      final closedPolyline = GeographicPolyline(accumulatedCoordinates);
      // add polyline to the appropriate polyline set
      if (innerWayIds.contains(workingWay.id)) {
        innerClosedPolylines.add(closedPolyline);
      }
      else {
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
            innerClosedPolylines.removeAt(i)
          );
        }
      }

      polygons.add(currentPolygon);
    }

    if (polygons.length > 1) {
      return GeometricOSMElement<OSMRelation, GeographicMultipolygon>(
        osmElement: osmRelation,
        geometry: GeographicMultipolygon(polygons)
      );
    }
    return GeometricOSMElement<OSMRelation, GeographicPolygon>(
      osmElement: osmRelation,
      geometry: polygons.single
    );
  }


  /// Extracts a ring (polygon) from the given ways starting with the initial way.
  /// This function connects ways that share an equal end/start point till a ring is formed.
  /// For cases where multiple ways connect at the same node this algorithm traverses all possible way-concatenations till a valid ring is found.
  /// It does this by creating a history of possible concatenations and backtracks if it couldn't find a valid ring.
  /// This is basically recursive but implemented in a non recursive way to mitigate any stack overflow.
  /// Throws an error if no ring could be built from the given ways

  static _WayNodeIdPool _extractRingFromWays(List<OSMWay> wayList, OSMWay initialWay) {
    // this is used to keep a history which is required for backtracking the algorithm
    final workingWayHistory = ListQueue<Iterator<_WayNodeIdPool>>();
    // add new way as initial history entry
    workingWayHistory.add(
      [_WayNodeIdPool(wayList, initialWay.nodeIds)].iterator
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

  static Iterable<_WayNodeIdPool> _getConnectingWays(List<OSMWay> wayList, int nodeId) sync* {
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
          way.nodeIds.reversed.skip(1)
        );
      }
      else if (way.nodeIds.first == nodeId) {
        // create a copy of the way list with all ways except the current way
        final subWayList = List.of(wayList)..removeAt(i);
        yield _WayNodeIdPool(
          subWayList,
          way.nodeIds.skip(1)
        );
      }
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GeometricOSMElement<T, G> &&
      other.osmElement.id == osmElement.id &&
      other.osmElement.type == osmElement.type;
  }

  @override
  int get hashCode => osmElement.id.hashCode ^ osmElement.type.hashCode;
}


class _WayNodeIdPool {
  final List<OSMWay> remainingWays;
  final Iterable<int> nodeIds;

  _WayNodeIdPool(this.remainingWays, this.nodeIds);
}
