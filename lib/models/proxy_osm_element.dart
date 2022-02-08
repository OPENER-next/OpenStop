import 'package:osm_api/osm_api.dart' as osmapi;

import '/models/osm_element_type.dart';

/// A wrapper class to modify [OSMElement]s without changing them.

class ProxyOSMElement<T extends osmapi.OSMElement> {

  ProxyOSMElement(T osmElement,
    { List<Map<String, String>>? changes }
  ) :
    _osmElement = osmElement
  {
    tags = Map.of(_osmElement.tags);
    changes?.forEach(tags.addAll);
  }

  final T _osmElement;

  /// Contains all original tags and those added by changes.

  late final Map<String, String> tags;

  int get id => _osmElement.id;

  int get version => _osmElement.version;

  OSMElementType get type => typeFromOSMElement(_osmElement);


  /// Applies all changes to the underlying osm element and returns it.

  T apply() {
    _osmElement.tags.addAll(tags);

    return _osmElement;
  }


  /// This method compares the type and id of the given element with the underlying [OSMElement]
  /// and returns true if they are identical.

  bool isSameElement(osmapi.OSMElement otherElement) =>
    _osmElement.id == otherElement.id &&
    _osmElement.type == otherElement.type;


  /// Two proxy elements are considered equal if they have the same type and id.

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return
      other is ProxyOSMElement<T> &&
      id == other.id &&
      type == other.type;
  }

  @override
  int get hashCode => id.hashCode ^ type.hashCode;
}
