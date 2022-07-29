
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
  /// The [osmNodes] parameter should contain all node elements that this way references.

  static GeometricOSMElement<OSMWay, GeographicGeometry> generateFromOSMWay({
    required OSMWay osmWay,
    required Iterable<OSMNode> osmNodes
  }) {
    final nodeList = osmNodes.toList();

    final geometry = GeographicPolyline(
      osmWay.nodeIds.map((nodeId) {
        final node = nodeList.firstWhere((node) => node.id == nodeId);
        return LatLng(node.lat, node.lon);
      }).toList()
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
    // filter all ways that are part of this relation
    var wayList = osmWays.where(
      (way) => osmRelation.members.any(
        (member) => member.ref == way.id && member.type == OSMElementType.way
      )
    ).toList();

    while (wayList.isNotEmpty) {
      final workingWay = wayList.removeLast();

      final wayNodePool = _extractRingFromWays(wayList, workingWay);

      final accumulatedCoordinates = wayNodePool.nodeIds.map((id) {
        // find node object by id
        final node = nodeList.firstWhere((node) => node.id == id);
        // convert node object to LatLng
        return LatLng(node.lat, node.lon);
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


  /// This automatically backtracks ...
  /// On success this wil automatically remove all ways that got extracted to the ring
  /// Throws an error if no ring could be built from the given way and ways

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

    throw 'Ring extraction failed.';
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
          way.nodeIds.reversed.skip(1).toList()
        );
      }
      else if (way.nodeIds.first == nodeId) {
        // create a copy of the way list with all ways except the current way
        final subWayList = List.of(wayList)..removeAt(i);
        yield _WayNodeIdPool(
          subWayList,
          way.nodeIds.skip(1).toList()
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
