import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:latlong2/latlong.dart';
import 'package:osm_api/osm_api.dart' as osmapi;

import '/api/osm_element_upload_api.dart';
import '/utils/osm_tag_area_resolver.dart';
import '/models/geographic_geometries.dart';
import '/models/osm_element_type.dart';
import 'element_identifier.dart';

part 'processed_element.dart';
part 'processed_node.dart';
part 'processed_way.dart';
part 'processed_relation.dart';
part 'proxy_element.dart';


/// Base element that encapsulates an [OSMElement] from the [OSMAPI].
/// It prevents any mutations to the underlying element while allowing read access to the element's data.

/// Two elements are considered equal if they have the same [id] and [type].

abstract class BaseElement<T extends osmapi.OSMElement> extends ElementIdentifier {

  /// Do not manipulate this object except on upload.

  final T _osmElement;

  BaseElement(this._osmElement);

  @override
  int get id => _osmElement.id;

  @override
  osmapi.OSMElementType get type => _osmElement.type;

  /// Returns the special [OSMElementType] which makes distinguishes between closed and open ways.

  OSMElementType get specialType {
    switch (_osmElement.type) {
      case osmapi.OSMElementType.node:
      return OSMElementType.node;

      case osmapi.OSMElementType.way:
      return (_osmElement as osmapi.OSMWay).isClosed
        ? OSMElementType.closedWay
        : OSMElementType.openWay;

      case osmapi.OSMElementType.relation:
      return OSMElementType.relation;
    }
  }


  Map<String, String> get tags => UnmodifiableMapView(_osmElement.tags);

  int get version => _osmElement.version;

  /// Check whether the underlying OSM element equals the given element.

  bool isOriginal(osmapi.OSMElement element) => _osmElement == element;
}
