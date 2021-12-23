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
}
