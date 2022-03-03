import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';

/// A network tile provider that exposes the HTTP headers parameter.

class NetworkTileProviderWithHeaders extends TileProvider {
  final Map<String, String>? headers;

  NetworkTileProviderWithHeaders([
    this.headers
  ]);

  @override
  ImageProvider getImage(Coords<num> coords, TileLayerOptions options) {
    return NetworkImage(getTileUrl(coords, options), headers: headers);
  }
}
