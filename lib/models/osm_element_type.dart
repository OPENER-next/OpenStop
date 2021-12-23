import 'package:osm_api/osm_api.dart' as osmapi;

/// This [enum] is a representation of the 4 OSM element types defined in the `question_catalog_schema.json`.

enum OSMElementType {
  Node, OpenWay, ClosedWay, Relation
}


/// A function that returns the name of the [OSMElementType] as a [String].

extension ParseToString on OSMElementType {
  String toShortString() {
    switch (this) {
      case OSMElementType.Node: return 'Node';
      case OSMElementType.OpenWay: return 'OpenWay';
      case OSMElementType.ClosedWay: return 'ClosedWay';
      case OSMElementType.Relation: return 'Relation';
    }
  }
}


/// A function that converts a [String] to the matching [OSMElementType] [enum] value.

extension ParseToOSMElementType on String {
  OSMElementType toOSMElementType() {
    switch (this) {
      case 'Node': return OSMElementType.Node;
      case 'OpenWay': return OSMElementType.OpenWay;
      case 'ClosedWay': return OSMElementType.ClosedWay;
      case 'Relation': return OSMElementType.Relation;
      default: throw Exception('Cannot convert String "$this" to OSMElementType.');
    }
  }
}


/// A function that returns the special [OSMElementType] from a given [OSMElement].

OSMElementType typeFromOSMElement(osmapi.OSMElement osmElement) {
  switch (osmElement.type) {
    case osmapi.OSMElementType.node:
    return OSMElementType.Node;

    case osmapi.OSMElementType.way:
    return (osmElement as osmapi.OSMWay).isClosed
      ? OSMElementType.ClosedWay
      : OSMElementType.OpenWay;

    case osmapi.OSMElementType.relation:
    return OSMElementType.Relation;
  }
}
