// SPDX-License-Identifier: GPL-3.0-or-later

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
