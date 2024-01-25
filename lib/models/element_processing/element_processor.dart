// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:osm_api/osm_api.dart';

import '/models/element_variants/base_element.dart';

/// This class is used to created [ProcessedElement]s from an [OSMElementBundle].
///
/// It adds any cross references to the elements and calculates their geometries.
///
/// Elements whose geometry could not be calculated will **not be included**.

class OSMElementProcessor {
  /// Nodes mapped to id for faster look up
  final _nodesLookUp = <int, ProcessedNode>{};
  /// Ways mapped to id for faster look up
  final _waysLookUp = <int, ProcessedWay>{};
  /// Relations mapped to id for faster look up
  final _relationsLookUp = <int, ProcessedRelation>{};

  OSMElementProcessor([ OSMElementBundle? elements ]) {
    if(elements != null) add(elements);
  }

  /// Returns all processed elements.

  Iterable<ProcessedElement> get elements sync* {
    yield* _nodesLookUp.values;
    yield* _waysLookUp.values;
    yield* _relationsLookUp.values;
  }

  /// Add and process elements.
  /// Already existing element will be discarded.
  ///
  /// Elements whose geometry could not be calculated will **not be included**.
  ///
  /// Returns all added elements and marks whether they are new or pre-existed.

  UnionSet<({ProcessedElement element, bool isNew})> add(OSMElementBundle elements) {
    // convert to Set so lazy iterables are evaluated
    // this is important since this adds the elements to the lookup tables
    final nodeRecords = _addNodes(elements.nodes).toSet();
    final wayRecords = _addWays(elements.ways).toSet();
    final relationRecords = _addRelations(elements.relations).toSet();

    // resolve references AFTER all elements have been added
    _resolveWays(wayRecords.map((item) => item.element));
    _resolveRelations(relationRecords.map((item) => item.element));

    // geometry calculation depends on parent/children assignment
    // due to inner dependencies first process nodes, then ways and then relations
    // also remove any elements where geometry calculation failed
    nodeRecords.removeWhere(
      (item) => _removeOnInvalidGeometry(item.element, _nodesLookUp),
    );
    wayRecords.removeWhere(
      (item) => _removeOnInvalidGeometry(item.element, _waysLookUp),
    );
    relationRecords.removeWhere(
      (item) => _removeOnInvalidGeometry(item.element, _relationsLookUp),
    );

    return UnionSet({
      nodeRecords, wayRecords, relationRecords,
    }, disjoint: true);
  }

  /// Fast way to get an element by it's type and id.

  ProcessedElement? find(OSMElementType type, int id) {
    switch (type) {
      case OSMElementType.node:
        return _nodesLookUp[id];
      case OSMElementType.way:
        return _waysLookUp[id];
      case OSMElementType.relation:
        return _relationsLookUp[id];
    }
  }

  /// Convert and add nodes **lazily** if not already existing.
  ///
  /// Returns all added nodes and marks if they are new or already existed.

  Iterable<({ProcessedNode element, bool isNew})> _addNodes(Iterable<OSMNode> nodes) sync* {
    for (final node in nodes) {
      var isNew = false;
      final pNode = _nodesLookUp.putIfAbsent(node.id, () {
        isNew = true;
        return ProcessedNode(node);
      });
      yield (element: pNode, isNew: isNew);
    }
  }

  /// Convert and add ways **lazily** if not already existing.
  ///
  /// Returns all newly added ways and marks if they are new or already existed.

  Iterable<({ProcessedWay element, bool isNew})> _addWays(Iterable<OSMWay> ways) sync* {
    for (final way in ways) {
      var isNew = false;
      final pWay = _waysLookUp.putIfAbsent(way.id, () {
        isNew = true;
        return ProcessedWay(way);
      });
      yield (element: pWay, isNew: isNew);
    }
  }

  /// Convert and add relations **lazily** if not already existing.
  ///
  /// Returns all newly added relations and marks if they are new or already existed.

  Iterable<({ProcessedRelation element, bool isNew})> _addRelations(Iterable<OSMRelation> relations) sync* {
    for (final relation in relations) {
      var isNew = false;
      final pRelation = _relationsLookUp.putIfAbsent(relation.id, () {
        isNew = true;
        return ProcessedRelation(relation);
      });
      yield (element: pRelation, isNew: isNew);
    }
  }

  /// Assigns all available children per way.

  void _resolveWays(Iterable<ProcessedWay> ways) {
    for (final pWay in ways) {
      for (final nodeId in pWay.nodeIds) {
        final pNode = _nodesLookUp[nodeId]!;
        pWay.addChild(pNode);
      }
    }
  }

  /// Assigns all available children per relation.

  void _resolveRelations(Iterable<ProcessedRelation> relations) {
    for (final pRelation in relations) {
      for (final member in pRelation.members) {
        final child = find(member.type, member.ref);
        // relations my reference objects that are not present in the bundle
        if (child != null) pRelation.addChild(child as ChildElement);
      }
    }
  }

  /// Calculates the geometry for the given element and removes the element from the given lookup table on failure.
  ///
  /// Returns `true` if geometry calculation failed.

  bool _removeOnInvalidGeometry(ProcessedElement element, Map<int, ProcessedElement> lookupTable) {
    try {
      element.calcGeometry();
      return false;
    }
    // catch geometry calculation errors
    catch(e) {
      debugPrint('Remove failed geometry: $element due to ${e.toString()}');
      lookupTable.remove(element.id);
      return true;
    }
  }
}
