import 'package:flutter/material.dart';

/// A unique identifier for a [_TileLayerDefinition] used in the [tileLayers] map.

enum TileLayerId {
  satelliteImagery,
  openStreetMap,
  publicTransport,
}

/// A map of tile layers used in the app.

const tileLayers = {
  TileLayerId.satelliteImagery: _TileLayerDefinition(
    name: 'Satellit',
    icon: Icons.satellite_rounded,
    templateUrl: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
    creditsText: 'Tiles © Esri — Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community'
  ),
  TileLayerId.openStreetMap: _TileLayerDefinition(
    name: 'Map',
    templateUrl: 'https://osm-2.nearest.place/retina/{z}/{x}/{y}.png',
    creditsText: '© Nearest!',
    creditsUrl: 'https://nearest.place'
  ),
  TileLayerId.publicTransport: _TileLayerDefinition(
    name: 'ÖPNV',
    templateUrl: 'https://tileserver.memomaps.de/tilegen/{z}/{x}/{y}.png',
    creditsText: 'Map memomaps.de CC-BY-SA',
    creditsUrl: 'https://memomaps.de/'
  ),
};


/// Contains functional and legal information of a pixel tile layer.

class _TileLayerDefinition {

  /// The label of the tile layer.

  final String name;

  /// The tile server URL template string by which to query tiles.
  /// For example: https://tile.openstreetmap.org/{z}/{x}/{y}.png

  final String templateUrl;

  /// A separate tile server URL template string that should be used in dark mode.

  final String? darkVariantTemplateUrl;

  final int maxZoom;
  final int minZoom;

  /// An optional icon that visually describes this tile layer.

  final IconData? icon;

  /// The credits text that should to be displayed to legally use this tile layer.

  final String creditsText;

  /// The website that the credits text should point to, if any.

  final String? creditsUrl;

  const _TileLayerDefinition({
    required this.name,
    required this.templateUrl,
    required this.creditsText,
    this.icon,
    this.darkVariantTemplateUrl,
    this.creditsUrl,
    this.maxZoom = 18,
    this.minZoom = 0
  });
}
