import 'dart:async';
import 'dart:math';

import 'package:animated_marker_layer/animated_marker_layer.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:supercluster/supercluster.dart';

import '/utils/stream_utils.dart';
import '/models/geometric_osm_element.dart';
import '/models/map_feature_collection.dart';
import '/view_models/questionnaire_provider.dart';
import '/widgets/osm_element_layer/osm_element_marker.dart';


class OsmElementLayer extends StatefulWidget {
  final Iterable<GeometricOSMElement> geoElements;

  final void Function(GeometricOSMElement osmElement)? onOsmElementTap;

  /// The maximum shift in duration between different markers.

  final Duration durationOffsetRange;

  /// The lowest zoom level on which the layer is still visible.

  final int zoomLowerLimit;

  const OsmElementLayer({
    required this.geoElements,
    this.onOsmElementTap,
    this.durationOffsetRange = const Duration(milliseconds: 300),
    this.zoomLowerLimit = 15,
    Key? key
  }) : super(key: key);

  @override
  State<OsmElementLayer> createState() => _OsmElementLayerState();
}

class _OsmElementLayerState extends State<OsmElementLayer> {
  Supercluster<GeometricOSMElement>? _supercluster;

  Stream<int>? _zoomLevelStream;


  @override
  void initState() {
    super.initState();

    compute(_cluster, widget.geoElements.toList()).then(
     (value) {
        setState(() =>_supercluster = value);
      }
    );
  }


  @override
  void didUpdateWidget(covariant OsmElementLayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    compute(_cluster, widget.geoElements.toList()).then(
      (value) {
        setState(() =>_supercluster = value);
      }
    );
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_zoomLevelStream == null) {
      final mapController = context.read<MapController>();
      _zoomLevelStream = mapController.mapEventStream
        .whereType<MapEventMove>()
        // some simple predictive zoom rounding
        // when zooming out always floor the current zoom, when zooming in round it
        // so markers get shown midway on zooming in but immediately hidden on zooming out
        .map((event) {
          return event.targetZoom < event.zoom
            ? event.targetZoom.floor()
            : event.targetZoom.round();
        })
        .transform(ComparePreviousTransformer(
          (previous, current) => previous != current
        ));
    }
  }


  static Supercluster<GeometricOSMElement> _cluster(List<GeometricOSMElement> elements) {
    return Supercluster<GeometricOSMElement>(
      points: elements,
      getX: (p) => p.geometry.center.longitude,
      getY: (p) => p.geometry.center.latitude,
      minZoom: 0,
      maxZoom: 20,
      radius: 120,
      extent: 512,
      nodeSize: 64,
      extractClusterData: (customMapPoint) => _ClusterLeafs([customMapPoint])
    );
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _zoomLevelStream,
      initialData: 0,
      builder: (context, snapshot) {
        final zoomLevel = snapshot.requireData;
        final visibleMarkers = <AnimatedMarker>[];
        final suppressedMarkers = <AnimatedMarker>[];

        if (_supercluster != null) {
          final clusters =_supercluster!.getClustersAndPoints(-180, -85, 180, 85, zoomLevel);

          for (final cluster in clusters) {
            if (cluster is Cluster<GeometricOSMElement>) {
              final points = (cluster.clusterData as _ClusterLeafs).elements;
              // always show the first element from yield as a marker and not placeholder
              visibleMarkers.add(
                _createMarker(points.first)
              );
              // skip first point since it is build as a marker
              suppressedMarkers.addAll(
                points.skip(1).map(_createMinimizedMarker)
              );
            }
            else if (cluster is MapPoint<GeometricOSMElement>) {
              visibleMarkers.add(
                _createMarker(cluster.originalPoint)
              );
            }
          }
        }

        // hide layer when zooming out passing the lower zoom limit
        return AnimatedSwitcher(
          // instantly show the animated marker layer since the markers themselves will be animated in
          duration: Duration.zero,
          reverseDuration: const Duration(milliseconds: 300),
          child: zoomLevel >= widget.zoomLowerLimit
            ? Stack(
              children: [
                AnimatedMarkerLayer(
                  markers: suppressedMarkers,
                ),
                AnimatedMarkerLayer(
                  markers: visibleMarkers,
                )
              ],
            )
            : null
        );
      }
    );
  }


  Duration _getRandomDelay([int? seed]) {
    if (widget.durationOffsetRange.inMicroseconds == 0) {
      return Duration.zero;
    }
    final randomTimeOffset = Random(seed).nextInt(widget.durationOffsetRange.inMicroseconds);
    return Duration(microseconds: randomTimeOffset);
  }


  AnimatedMarker _createMarker(GeometricOSMElement geoElement) {
    // supply id as seed so we get the same delay for both marker types
    final seed = geoElement.osmElement.id;
    return _OsmElementMarker(
      geoElement: geoElement,
      animateInDelay: _getRandomDelay(seed),
      animateOutDelay: _getRandomDelay(seed),
      builder: _markerBuilder
    );
  }


  Widget _markerBuilder(BuildContext context, Animation<double> animation, AnimatedMarker marker) {
    marker as _OsmElementMarker;
    final osmElement = marker.geoElement.osmElement;
    final mapFeature = context.watch<MapFeatureCollection>().getMatchingFeature(osmElement);
    final activeElement = context.watch<QuestionnaireProvider>().workingElement;
    final hasNoActive = activeElement == null;
    final isActive = activeElement?.isProxiedElement(osmElement) ?? false;

    return ScaleTransition(
      scale: animation,
      alignment: Alignment.bottomCenter,
      child: OsmElementMarker(
        onTap: () => widget.onOsmElementTap?.call(marker.geoElement),
        backgroundColor: isActive || hasNoActive ? null : Colors.grey,
        icon: mapFeature?.icon ?? CommunityMaterialIcons.help_rhombus_outline
      )
    );
  }


  AnimatedMarker _createMinimizedMarker(GeometricOSMElement geoElement) {
    final osmElement = geoElement.osmElement;

    return AnimatedMarker(
      key: ValueKey(osmElement),
      point: geoElement.geometry.center,
      size: const Size.fromRadius(4),
      animateInCurve: Curves.easeIn,
      animateOutCurve: Curves.easeOut,
      animateInDuration: const Duration(milliseconds: 300),
      animateOutDuration: const Duration(milliseconds: 300),
      // supply id as seed so we get the same delay for both marker types
      animateInDelay: _getRandomDelay(osmElement.id),
      animateOutDelay: _getRandomDelay(osmElement.id),
      builder: _minimizedMarkerBuilder
    );
  }


  Widget _minimizedMarkerBuilder(BuildContext context, Animation<double> animation, _) {
    return FadeTransition(
      opacity: animation,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            width: 1,
            color: Colors.black26
          )
        )
      )
    );
  }
}


class _OsmElementMarker extends AnimatedMarker {
  final GeometricOSMElement geoElement;

  _OsmElementMarker({
    required this.geoElement,
    required super.builder,
    required super.animateInDelay,
    required super.animateOutDelay,
  }) : super(
    key: ValueKey(geoElement.osmElement),
    point: geoElement.geometry.center,
    size: const Size.square(60),
    anchor: Alignment.bottomCenter,
    animateInCurve: Curves.elasticOut,
    animateOutCurve: Curves.easeOutBack,
    animateOutDuration: const Duration(milliseconds: 300),
  );
}


class _ClusterLeafs extends ClusterDataBase {
  final List<GeometricOSMElement> elements;

  _ClusterLeafs(this.elements);

  @override
  _ClusterLeafs combine(_ClusterLeafs other) {
    return _ClusterLeafs(elements + other.elements);
  }
}
