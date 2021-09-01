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
      default: throw(Exception('Cannot convert String "$this" to OSMElementType.'));
    }
  }
}
