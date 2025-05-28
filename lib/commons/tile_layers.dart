const _thunderforestAPIKey = String.fromEnvironment('THUNDERFOREST_API_KEY', defaultValue: '');

/// A map of tile layers used in the app.

const kTileLayerPublicTransport = TileLayerDefinition(
  name: 'Public Transport',
  templateUrl:
      'https://tile.thunderforest.com/transport/{z}/{x}/{y}{r}.png?apikey=$_thunderforestAPIKey',
  darkVariantTemplateUrl:
      'https://tile.thunderforest.com/transport-dark/{z}/{x}/{y}{r}.png?apikey=$_thunderforestAPIKey',
  attributionText: 'Maps © Thunderforest',
  attributionUrl: 'https://www.thunderforest.com',
  maxZoom: 22,
  minZoom: 3,
);

/// Contains functional and legal information of a pixel tile layer.

class TileLayerDefinition {
  /// The label of the tile layer.

  final String name;

  /// The tile server URL template string by which to query tiles.
  /// For example: https://tile.openstreetmap.org/{z}/{x}/{y}.png

  final String templateUrl;

  /// A separate tile server URL template string that should be used in dark mode.

  final String? darkVariantTemplateUrl;

  final int maxZoom;
  final int minZoom;

  /// The attribution text that should to be displayed to legally use this tile layer.

  final String attributionText;

  /// The website that the attribution text should point to, if any.

  final String? attributionUrl;

  const TileLayerDefinition({
    required this.name,
    required this.templateUrl,
    required this.attributionText,
    this.darkVariantTemplateUrl,
    this.attributionUrl,
    this.maxZoom = 18,
    this.minZoom = 0,
  });
}
