import 'dart:async';
import 'dart:math';

import 'package:animated_marker_layer/animated_marker_layer.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:supercluster/supercluster.dart';

import '/utils/stream_utils.dart';
import '/models/element_variants/base_element.dart';
import '/models/map_feature_collection.dart';
import '/view_models/questionnaire_provider.dart';
import '/widgets/osm_element_layer/osm_element_marker.dart';


class OsmElementLayer extends StatefulWidget {
  final Iterable<ProcessedElement> elements;

  final void Function(ProcessedElement osmElement)? onOsmElementTap;

  /// The maximum shift in duration between different markers.

  final Duration durationOffsetRange;

  /// The lowest zoom level on which the layer is still visible.

  final int zoomLowerLimit;

  const OsmElementLayer({
    required this.elements,
    this.onOsmElementTap,
    this.durationOffsetRange = const Duration(milliseconds: 300),
    this.zoomLowerLimit = 15,
    Key? key
  }) : super(key: key);

  @override
  State<OsmElementLayer> createState() => _OsmElementLayerState();
}

class _OsmElementLayerState extends State<OsmElementLayer> {
  SuperclusterImmutable<ProcessedElement>? _supercluster;

  Stream<int>? _zoomLevelStream;


  @override
  void initState() {
    super.initState();

    compute(_cluster, widget.elements.toList()).then(
     (value) {
        setState(() =>_supercluster = value);
      }
    );
  }


  @override
  void didUpdateWidget(covariant OsmElementLayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    compute(_cluster, widget.elements.toList()).then(
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
        .whereType<MapEventWithMove>()
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


  static SuperclusterImmutable<ProcessedElement> _cluster(List<ProcessedElement> elements) {
    return SuperclusterImmutable<ProcessedElement>(
      getX: (p) => p.geometry.center.longitude,
      getY: (p) => p.geometry.center.latitude,
      minZoom: 0,
      maxZoom: 20,
      radius: 120,
      extent: 512,
      nodeSize: 64,
      extractClusterData: (customMapPoint) => _ClusterLeafs([customMapPoint])
    )..load(elements);
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
        final questionnaireProvider = context.watch<QuestionnaireProvider>();

        if (_supercluster != null) {
          final clusters =_supercluster!.search(-180, -85, 180, 85, zoomLevel);
          var activeMarkerFound = false;

          for (final cluster in clusters) {
            final elements = _elementsFromCluster(cluster).iterator;

            if (questionnaireProvider.isOpen) {
              while(!activeMarkerFound && elements.moveNext()) {
                if (questionnaireProvider.workingElement == elements.current) {
                  visibleMarkers.add(
                    _createMarker(elements.current)
                  );
                  activeMarkerFound = true;
                }
                else {
                  suppressedMarkers.add(_createMinimizedMarker(elements.current));
                }
              }
            }
            else {
              // always show the first element as a marker and not placeholder
              visibleMarkers.add(
                _createMarker((elements..moveNext()).current)
              );
            }
            while(elements.moveNext()) {
              suppressedMarkers.add(_createMinimizedMarker(elements.current));
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
                ),
              ],
            )
            : null
        );
      }
    );
  }


  Iterable<ProcessedElement> _elementsFromCluster(cluster) sync* {
    if (cluster is ImmutableLayerCluster<ProcessedElement>) {
      yield* (cluster.clusterData as _ClusterLeafs).elements;
    }
    else if (cluster is ImmutableLayerPoint<ProcessedElement>) {
      yield cluster.originalPoint;
    }
  }


  Duration _getRandomDelay([int? seed]) {
    if (widget.durationOffsetRange.inMicroseconds == 0) {
      return Duration.zero;
    }
    final randomTimeOffset = Random(seed).nextInt(widget.durationOffsetRange.inMicroseconds);
    return Duration(microseconds: randomTimeOffset);
  }


  AnimatedMarker _createMarker(ProcessedElement element) {
    // supply id as seed so we get the same delay for both marker types
    final seed = element.id;
    return _OsmElementMarker(
      element: element,
      animateInDelay: _getRandomDelay(seed),
      builder: _markerBuilder
    );
  }


  Widget _markerBuilder(BuildContext context, Animation<double> animation, AnimatedMarker marker) {
    marker as _OsmElementMarker;
    final osmElement = marker.element;
    final mapFeature = context.watch<MapFeatureCollection>().getMatchingFeature(osmElement);
    final activeElement = context.watch<QuestionnaireProvider>().workingElement;
    final isActive = activeElement == osmElement;

    return ScaleTransition(
      scale: animation,
      alignment: Alignment.bottomCenter,
      filterQuality: FilterQuality.low,
      child: OsmElementMarker(
        onTap: () => widget.onOsmElementTap?.call(marker.element),
        active: isActive,
        icon: mapFeature?.icon ?? MdiIcons.help,
        label: mapFeature?.labelByElement(osmElement) ?? mapFeature?.name ?? '',
      )
    );
  }


  AnimatedMarker _createMinimizedMarker(ProcessedElement element) {
    return AnimatedMarker(
      // use geo element as key, because osm element equality changes whenever its tags or version change
      // while geo elements only compare the OSM element type and id
      key: ValueKey(element),
      point: element.geometry.center,
      size: const Size.fromRadius(4),
      animateInCurve: Curves.easeIn,
      animateOutCurve: Curves.easeOut,
      animateInDuration: const Duration(milliseconds: 300),
      animateOutDuration: const Duration(milliseconds: 300),
      // supply id as seed so we get the same delay for both marker types
      animateOutDelay: _getRandomDelay(element.id),
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
            color: Theme.of(context).colorScheme.shadow
          )
        )
      )
    );
  }
}


class _OsmElementMarker extends AnimatedMarker {
  final ProcessedElement element;

  _OsmElementMarker({
    required this.element,
    required super.builder,
    super.animateInDelay,
  }) : super(
    // use processed element as key
    // its equality doesn't change when its tags or version changes
    key: ValueKey(element),
    point: element.geometry.center,
    size: const Size(260, 60),
    anchor: Alignment.bottomCenter,
    animateInCurve: Curves.elasticOut,
    animateOutCurve: Curves.easeOutBack,
    animateOutDuration: const Duration(milliseconds: 300),
  );
}


class _ClusterLeafs extends ClusterDataBase {
  final List<ProcessedElement> elements;

  _ClusterLeafs(this.elements);

  @override
  _ClusterLeafs combine(_ClusterLeafs other) {
    return _ClusterLeafs(elements + other.elements);
  }
}
