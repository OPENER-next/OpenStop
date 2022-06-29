import 'dart:math';

import 'package:animated_marker_layer/animated_marker_layer.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/models/map_feature_collection.dart';
import '/models/geometric_osm_element.dart';
import '/models/proxy_osm_element.dart';
import '/widgets/osm_element_layer/osm_element_marker.dart';
import '/view_models/questionnaire_provider.dart';

class OsmElementLayer extends StatefulWidget {
  final Iterable<GeometricOSMElement> geoElements;

  final void Function(GeometricOSMElement osmElement)? onOsmElementTap;

  /// The maximum shift in duration between different markers.

  final Duration durationOffsetRange;

  const OsmElementLayer({
    required this.geoElements,
    this.onOsmElementTap,
    this.durationOffsetRange = const Duration(milliseconds: 300),
    Key? key
  }) : super(key: key);

  @override
  State<OsmElementLayer> createState() => _OsmElementLayerState();
}

class _OsmElementLayerState extends State<OsmElementLayer> {
  static Widget _animateInOutBuilder(BuildContext context, Animation<double> animation, Widget child) {
    return Transform.scale(
      scale: animation.value,
      alignment: Alignment.bottomCenter,
      child: child
    );
  }

  final _random = Random();

  @override
  Widget build(BuildContext context) {
    return AnimatedMarkerLayer(
      markers: widget.geoElements.map(_buildMarker).toList(),
    );
  }


  Duration _getRandomDelay() {
    if (widget.durationOffsetRange.inMicroseconds == 0) {
      return Duration.zero;
    }
    final randomTimeOffset = _random.nextInt(widget.durationOffsetRange.inMicroseconds);
    return Duration(microseconds: randomTimeOffset);
  }


  AnimatedMarker _buildMarker(GeometricOSMElement geoElement) {
    final osmElement = geoElement.osmElement;
    final mapFeature = context.watch<MapFeatureCollection>().getMatchingFeature(osmElement);

    return AnimatedMarker(
      key: ValueKey(osmElement),
      point: geoElement.geometry.center,
      size: const Size.square(60),
      anchor: Alignment.bottomCenter,
      animateInBuilder: _animateInOutBuilder,
      animateOutBuilder: _animateInOutBuilder,
      animateInDelay: _getRandomDelay(),
      animateOutDelay: _getRandomDelay(),
      // only rebuild when working element changes
      child: Selector<QuestionnaireProvider, ProxyOSMElement?>(
        selector: (_, questionnaire) => questionnaire.workingElement,
        builder: (context, activeElement, child) {
          final hasNoActive = activeElement == null;
          final isActive = activeElement?.isProxiedElement(osmElement) ?? false;
          return OsmElementMarker(
            onTap: () => widget.onOsmElementTap?.call(geoElement),
            backgroundColor: isActive || hasNoActive ? null : Colors.grey, // Color(0xffd39690), //Theme.of(context).colorScheme.primary.withOpacity(0.75),
            icon: mapFeature?.icon ?? CommunityMaterialIcons.help_rhombus_outline
          );
        },
      )
    );
  }
}
