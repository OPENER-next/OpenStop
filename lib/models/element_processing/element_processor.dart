import 'package:flutter/foundation.dart';
import 'package:osm_api/osm_api.dart';

import '/models/element_variants/base_element.dart';

/// This class is used to created [ProcessedElement]s from an [OSMElementBundle].
/// It adds any cross references to the elements and calculates their geometries.

class OSMElementProcessor {
  /// Nodes mapped to id for faster look up
  final Map<int, ProcessedNode> _nodesLookUp;
  /// Ways mapped to id for faster look up
  final Map<int, ProcessedWay> _waysLookUp;
  /// Relations mapped to id for faster look up
  final Map<int, ProcessedRelation> _relationsLookUp;

  OSMElementProcessor(
    OSMElementBundle elements,
  ) : _nodesLookUp = _mapNodes(elements),
      _waysLookUp = _mapWays(elements),
      _relationsLookUp = _mapRelations(elements);

  static Map<int, ProcessedNode> _mapNodes (OSMElementBundle elements) => {
    for (var node in elements.nodes) node.id: ProcessedNode(node)
  };

  static Map<int, ProcessedWay> _mapWays (OSMElementBundle elements) => {
    for (var way in elements.ways) way.id: ProcessedWay(way)
  };

  static Map<int, ProcessedRelation> _mapRelations (OSMElementBundle elements) => {
    for (var relation in elements.relations) relation.id: ProcessedRelation(relation)
  };

  /// Returns all processed elements.

  Iterable<ProcessedElement> get _processedElements sync* {
    yield* _nodesLookUp.values;
    yield* _waysLookUp.values;
    yield* _relationsLookUp.values;
  }

  /// Assigns all available children/parents per way.

  void _resolveWays() {
    for (final pWay in _waysLookUp.values) {
      for (final nodeId in pWay.nodeIds) {
        final pNode = _nodesLookUp[nodeId]!;
        pWay.addChild(pNode);
      }
    }
  }

  /// Assigns all available children/parents per relation.

  void _resolveRelations() {
    for (final pRelation in _relationsLookUp.values) {
      for (final member in pRelation.members) {
        final ProcessedElement? child;
        switch (member.type) {
          case OSMElementType.node:
            child = _nodesLookUp[member.ref];
          break;
          case OSMElementType.way:
            child = _waysLookUp[member.ref];
          break;
          case OSMElementType.relation:
            child = _relationsLookUp[member.ref];
          break;
        }
        // relations my reference objects that are not present in the bundle
        if (child != null) pRelation.addChild(child as ChildElement);
      }
    }
  }

  /// Calculates the geometry for every element.
  ///
  /// Removes elements whose geometry calculation failed.

  void _calcGeometries(Map<int, ProcessedElement> elements) {
    // remove elements where geometry calculation failed
    elements.removeWhere((id, element) {
      try {
        element.calcGeometry();
        return false;
      }
      // catch geometry calculation errors
      catch(e) {
        debugPrint(e.toString());
        return true;
      }
    });
  }

  /// Processes all elements and returns them as an [Iterable].
  ///
  /// Elements whose geometry could not be calculated will be filtered here.

  Iterable<ProcessedElement> process() {
    // resolve all references
    _resolveWays();
    _resolveRelations();
    // geometry calculation depends on parent/children assignment
    // due to inner dependencies first process nodes, then ways and then relations
    _calcGeometries(_nodesLookUp);
    _calcGeometries(_waysLookUp);
    _calcGeometries(_relationsLookUp);
    return _processedElements;
  }
}
