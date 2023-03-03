part of 'base_element.dart';

/// Concrete implementation of [ProcessedElement] for OSM nodes.
/// See [ProcessedElement] for details.

class ProcessedNode extends ProcessedElement<osmapi.OSMNode, GeographicPoint> with ChildElement {
  ProcessedNode(super.element);

  @override
  void calcGeometry() {
    _geometry = GeographicPoint(
      LatLng(_osmElement.lat, _osmElement.lon),
    );
  }
}
