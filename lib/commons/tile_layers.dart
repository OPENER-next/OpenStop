/// A unique identifier for a [_TileLayerDefinition] used in the [tileLayers] map.

enum TileLayerId {
  satelliteImagery,
  openStreetMap,
  publicTransport,
}

/// A map of tile layers used in the app.

const tileLayers = {
  TileLayerId.satelliteImagery: _TileLayerDefinition(
    templateUrl: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
    creditsText: 'credit text here'
  ),
  TileLayerId.openStreetMap: _TileLayerDefinition(
    templateUrl: 'https://osm-2.nearest.place/retina/{z}/{x}/{y}.png',
    creditsText: 'credit text here'
  ),
  TileLayerId.publicTransport: _TileLayerDefinition(
    templateUrl: 'https://tileserver.memomaps.de/tilegen/{z}/{x}/{y}.png',
    creditsText: 'credit text here'
  ),
};


/// Contains functional and legal information of a pixel tile layer.

class _TileLayerDefinition {

  /// The tile server URL template string by which to query tiles.
  /// For example: https://tile.openstreetmap.org/{z}/{x}/{y}.png

  final String templateUrl;

  /// A separate tile server URL template string that should be used in dark mode.

  final String? darkVariantTemplateUrl;

  final int maxZoom;
  final int minZoom;

  /// The credits text that should to be displayed to legally use this tile layer.

  final String creditsText;

  /// The website that the credits text should point to, if any.

  final String? creditsUrl;

  const _TileLayerDefinition({
    required this.templateUrl,
    required this.creditsText,
    this.darkVariantTemplateUrl,
    this.creditsUrl,
    this.maxZoom = 18,
    this.minZoom = 0
  });
}
