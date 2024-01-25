// SPDX-License-Identifier: GPL-3.0-or-later

part of 'base_element.dart';

/// Concrete implementation of [ProcessedElement] for OSM ways.
/// See [ProcessedElement] for details.
///
/// The geometry calculation requires adding all child nodes in beforehand via `addChild`.

class ProcessedWay extends ProcessedElement<osmapi.OSMWay, GeographicGeometry> with ChildElement, ParentElement {
  ProcessedWay(super.element);

  Iterable<int> get nodeIds => Iterable.castFrom(_osmElement.nodeIds);

  @override
  UnmodifiableSetView<ProcessedRelation> get parents => UnmodifiableSetView(_parents.cast<ProcessedRelation>());

  @override
  UnmodifiableSetView<ProcessedNode> get children => UnmodifiableSetView(_children.cast<ProcessedNode>());

  @override
  void addParent(ProcessedRelation element) => super.addParent(element);

  @override
  void removeParent(ProcessedRelation element) => super.removeParent(element);

  @override
  void addChild(ProcessedNode element) => super.addChild(element);

  @override
  void removeChild(ProcessedNode element) => super.removeChild(element);

  /// All nodes that this way references must be added before calling this via `addChild`.

  @override
  void calcGeometry() {
    // assert that the provided nodes are exactly the ones referenced by the way and in the same order
    assert(
      _osmElement.nodeIds.every((id) => _children.any((ele) => ele.id == id)),
      'OSM way $id references nodes that cannot be found in the provided node data set.'
    );

    final accumulatedCoordinates = _osmElement.nodeIds
      .map((nodeId) {
        final element = children.firstWhere((element) => nodeId == element.id);
        return element.geometry.center;
      })
      .toList();

    final geometry = GeographicPolyline(accumulatedCoordinates);

    if (_osmElement.isClosed && isArea(_osmElement.tags)) {
      _geometry = GeographicPolygon( outerShape: geometry );
    }
    else {
      _geometry = geometry;
    }
  }
}
