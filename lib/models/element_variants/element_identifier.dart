import 'package:osm_api/osm_api.dart' as osmapi;

/// Base class in order to identify and compare OSM elements.
///
/// Two elements are considered equal if they have the same [id] and [type].

abstract class ElementIdentifier {
  const ElementIdentifier();

  int get id;

  osmapi.OSMElementType get type;

  /// Two elements are considered equal if they have the same [id] and [type].

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ElementIdentifier &&
      other.id == id &&
      other.type == type;
  }

  @override
  int get hashCode => id.hashCode ^ type.hashCode;
}
