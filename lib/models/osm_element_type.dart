import 'package:osm_api/osm_api.dart' as osmapi;

/// This [enum] is a representation of the 4 OSM element types defined in the `question_catalog_schema.json`.

enum OSMElementType {
  node, openWay, closedWay, relation
}


/// A function that returns the name of the [OSMElementType] as a [String].

extension ParseToString on OSMElementType {
  String toShortString() {
    switch (this) {
      case OSMElementType.node: return 'Node';
      case OSMElementType.openWay: return 'OpenWay';
      case OSMElementType.closedWay: return 'ClosedWay';
      case OSMElementType.relation: return 'Relation';
    }
  }
}


/// A function that converts a [String] to the matching [OSMElementType] [enum] value.

extension ParseToOSMElementType on String {
  OSMElementType toOSMElementType() {
    switch (this) {
      case 'Node': return OSMElementType.node;
      case 'OpenWay': return OSMElementType.openWay;
      case 'ClosedWay': return OSMElementType.closedWay;
      case 'Relation': return OSMElementType.relation;
      default: throw Exception('Cannot convert String "$this" to OSMElementType.');
    }
  }
}


/// A function that returns the special [OSMElementType] from a given [OSMElement].
/// Note: Enums cannot have static methods or constructors via extensions. Because of that this is defined as a "global" method.

OSMElementType typeFromOSMElement(osmapi.OSMElement osmElement) {
  switch (osmElement.type) {
    case osmapi.OSMElementType.node:
    return OSMElementType.node;

    case osmapi.OSMElementType.way:
    return (osmElement as osmapi.OSMWay).isClosed
      ? OSMElementType.closedWay
      : OSMElementType.openWay;

    case osmapi.OSMElementType.relation:
    return OSMElementType.relation;
  }
}
