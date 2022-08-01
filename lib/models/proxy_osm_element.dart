import 'package:collection/collection.dart';
import 'package:osm_api/osm_api.dart' as osmapi;

import '/models/osm_element_type.dart';

/// A wrapper class to modify [OSMElement]s without changing or exposing them.
/// Two proxy elements are considered equal if they have the same [id] and [type].

class ProxyOSMElement<T extends osmapi.OSMElement> {
  final T _osmElement;

  ProxyOSMElement(T osmElement, {
    Map<String, String> additionalTags = const {},
  }) :
    _osmElement = osmElement,
    tags = CombinedMapView([
      // on duplicates the first value will be returned
      // therefore move _additionalTags to the start
      additionalTags, osmElement.tags
    ]);

  /// Contains all original tags and those added by changes.

  final CombinedMapView<String, String> tags;

  int get id => _osmElement.id;

  int get version => _osmElement.version;

  osmapi.OSMElementType get type => _osmElement.type;

  OSMElementType get specialType =>  typeFromOSMElement(_osmElement);


  /// Applies all changes to a copy of the underlying osm element and returns it.

  T apply() => _osmElement.copyWith(tags: tags) as T;


  /// This method checks whether the given element is the underlying [OSMElement].
  /// This means the type and id must be equal.

  bool isOther(osmapi.OSMElement other) {
    return other.id == id && other.type == type;
  }


  /// Two proxy elements are considered equal if they have the same [id] and [type].

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProxyOSMElement<T> &&
      id == other.id &&
      type == other.type;
  }

  @override
  int get hashCode => id.hashCode ^ type.hashCode;
}
