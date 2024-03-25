import 'package:flutter/widgets.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:osm_api/osm_api.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/models/element_variants/base_element.dart';
import '/models/element_variants/element_identifier.dart';
import '/models/geographic_geometries.dart';
import 'map_feature_definition.dart';

/// An OSM element representation.
///
/// This is usually instantiated by calling [MapFeatureDefinition.resolve].
///
/// [MapFeatureRepresentation] base its equality on its [id] and [type].

class MapFeatureRepresentation extends ElementIdentifier {

  const MapFeatureRepresentation({
    required this.id,
    required this.type,
    required this.geometry,
    required this.icon,
    required MapFeatureLabelConstructor label,
    required Map<String, String> tags,
    required this.uploadStatus,
  }) : _label = label, _tags = tags;

  MapFeatureRepresentation.fromElement({
    required ProcessedElement element,
    this.icon = MdiIcons.help,
    MapFeatureLabelConstructor label = _defaultLabel,
  }) :
    id = element.id,
    type = element.type,
    geometry = element.geometry,
    _tags = element.tags,
    uploadStatus = false,
    _label = label;

  static String _defaultLabel(AppLocalizations _, Map<String, String> tags) {
    return tags['name'] ?? tags['ref'] ?? 'Element';
  }

  MapFeatureRepresentation copyWith({
    int? id,
    OSMElementType? type,
    GeographicGeometry? geometry,
    IconData? icon,
    MapFeatureLabelConstructor? label,
    Map<String, String>? tags,
    bool? uploadStatus,
  }) {
    return MapFeatureRepresentation(
      id: id ?? this.id,
      type: type ?? this.type,
      geometry: geometry ?? this.geometry,
      icon: icon ?? this.icon,
      label: label ?? _label, // Not sure ifthe copy work ok
      tags: tags ?? _tags, //same
      uploadStatus: uploadStatus ?? this.uploadStatus,
    );
  }

  @override
  final int id;

  @override
  final OSMElementType type;

  final GeographicGeometry geometry;

  final IconData icon;

  final MapFeatureLabelConstructor _label;

  final Map<String, String> _tags;

  final bool uploadStatus;

  String genericLabel(AppLocalizations locale) => _label(locale, const {});

  String elementLabel(AppLocalizations locale) => _label(locale, _tags);
}
