import 'dart:async';
import 'dart:math';

import 'package:animated_marker_layer/animated_marker_layer.dart';
import 'package:flutter/material.dart';
import '/widgets/osm_element_layer/upload_animation.dart';
import 'package:supercluster/supercluster.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/models/map_features/map_feature_representation.dart';
import '/api/app_worker/element_handler.dart';
import '/widgets/osm_element_layer/osm_element_marker.dart';


class OsmElementLayer extends StatefulWidget {

  final Stream<ElementUpdate> elements;

  final MapFeatureRepresentation? selectedElement;

  final void Function(MapFeatureRepresentation osmElement)? onOsmElementTap;

  final Set<MapFeatureRepresentation> uploadQueue;

  /// The maximum shift in duration between different markers.

  final Duration durationOffsetRange;

  /// The current zoom level.

  final num currentZoom;

  /// The lowest zoom level on which the layer is still visible.

  final int zoomLowerLimit;

  const OsmElementLayer({
    required this.elements,
    required this.currentZoom,
    required this.uploadQueue,
    this.selectedElement,
    this.onOsmElementTap,
    this.durationOffsetRange = const Duration(milliseconds: 300),
    // TODO: currently changes to this won't update the super cluster
    this.zoomLowerLimit = 16,
    super.key
  });

  @override
  State<OsmElementLayer> createState() => _OsmElementLayerState();
}

class _OsmElementLayerState extends State<OsmElementLayer> {
  StreamSubscription<ElementUpdate>? _streamSubscription;

  late final _superCluster = SuperclusterMutable<MapFeatureRepresentation>(
    getX: (p) => p.geometry.center.longitude,
    getY: (p) => p.geometry.center.latitude,
    minZoom: widget.zoomLowerLimit,
    maxZoom: 20,
    radius: 120,
    extent: 512,
    nodeSize: 64,
    extractClusterData: (customMapPoint) => _ClusterLeafs([customMapPoint])
  );

  @override
  void initState() {
    super.initState();
    _streamSubscription = widget.elements.listen(_handleElementChange);
  }

  @override
  void didUpdateWidget(covariant OsmElementLayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.elements != oldWidget.elements) {
      _streamSubscription?.cancel();
      _streamSubscription = widget.elements.listen(_handleElementChange);
    }
  }

  void _handleElementChange(ElementUpdate change) {
    setState(() {
      if (change.action == ElementUpdateAction.clear) {
        _superCluster.load([]);
      }
      else if (change.action == ElementUpdateAction.update) {
        // _superCluster.containsPoint() will not globally check whether a point
        // has already been added.
        // So if the point position has been modified it may not find it.
        // Therefore use _superCluster.points.contains().
        if (_superCluster.points.contains(change.element!)) {
          _superCluster.modifyPointData(change.element!, change.element!);
        }
        else {
          _superCluster.add(change.element!);
        }
      }
      else if (change.action == ElementUpdateAction.remove){
        _superCluster.remove(change.element!);
      }
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleMarkers = <AnimatedMarker>[];
    final suppressedMarkers = <AnimatedMarker>[];

    if (widget.currentZoom >= widget.zoomLowerLimit) {
      final clusters = _superCluster.search(-180, -85, 180, 85, widget.currentZoom.toInt());
      var activeMarkerFound = false;

      for (final cluster in clusters) {
        // get elements from cluster
        final elements = _elementsFromCluster(cluster).iterator;

        if (widget.selectedElement != null) {
          while(!activeMarkerFound && elements.moveNext()) {
            if (widget.selectedElement == elements.current) {
              visibleMarkers.add(
                _createMarker(elements.current)
              );
              activeMarkerFound = true;
            }
            else {
              suppressedMarkers.add(_createMinimizedMarker(elements.current));
            }
          }
          while(elements.moveNext()) {
            suppressedMarkers.add(_createMinimizedMarker(elements.current));
          }
        }
        else {
          // loop over elements so that only the first one is a marker and not a placeholder
          if (elements.moveNext()) {
            visibleMarkers.add(
              _createMarker(elements.current),
            );
            while(elements.moveNext()) {
              suppressedMarkers.add(
                _createMinimizedMarker(elements.current)
              );
            }
          }
        }
      }
    }

    // hide layer when zooming out passing the lower zoom limit
    return AnimatedSwitcher(
      // instantly show the animated marker layer since the markers themselves will be animated in
      duration: Duration.zero,
      reverseDuration: const Duration(milliseconds: 300),
      child: widget.currentZoom >= widget.zoomLowerLimit
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


  Iterable<MapFeatureRepresentation> _elementsFromCluster(MutableLayerElement<MapFeatureRepresentation> cluster) sync* {
    if (cluster is MutableLayerCluster<MapFeatureRepresentation>) {
      yield* (cluster.clusterData as _ClusterLeafs).elements;
    }
    else if (cluster is MutableLayerPoint<MapFeatureRepresentation>) {
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


  AnimatedMarker _createMarker(MapFeatureRepresentation element) {
    // supply id as seed so we get the same delay for both marker types
    final seed = element.id;
    return _OsmElementMarker(
      element: element,
      animateInDelay: _getRandomDelay(seed),
      builder: _markerBuilder
    );
  }


  Widget _markerBuilder(BuildContext context, Animation<double> animation, AnimatedMarker marker) {
    final appLocale = AppLocalizations.of(context)!;
    marker as _OsmElementMarker;
    final isActive = widget.selectedElement == marker.element;
    final isUploading = widget.uploadQueue.contains(marker.element);

    return ScaleTransition(
      scale: animation,
      alignment: Alignment.bottomCenter,
      filterQuality: FilterQuality.low,
      child: UploadAnimation(
        active: isUploading,
        particleDuration: 1000,
        particleOverflow: 40,
        particleColor: Theme.of(context).colorScheme.primary,
        particleLanes: 4,
        particleOffset: const Offset(0, -45),
        child: OsmElementMarker(
          onTap: () => widget.onOsmElementTap?.call(marker.element),
          active: isActive,
          icon: isUploading
            ? Icons.cloud_upload_rounded
            : marker.element.icon,
          label: marker.element.elementLabel(appLocale),
        ),
      ),
    );
  }

  AnimatedMarker _createMinimizedMarker(MapFeatureRepresentation element) {
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
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.26)
          )
        )
      )
    );
  }
}


class _OsmElementMarker extends AnimatedMarker {
  final MapFeatureRepresentation element;

  _OsmElementMarker({
    required this.element,
    required super.builder,
    super.animateInDelay,
  }) : super(
    // use ElementIdentifier as key
    // its equality doesn't change when its tags or version changes
    key: ValueKey(element),
    point: element.geometry.center,
    size: const Size(260, 100),
    anchor: Alignment.bottomCenter,
    animateInCurve: Curves.elasticOut,
    animateOutCurve: Curves.easeOutBack,
    animateOutDuration: const Duration(milliseconds: 300),
  );
}


class _ClusterLeafs extends ClusterDataBase {
  final List<MapFeatureRepresentation> elements;

  _ClusterLeafs(this.elements);

  @override
  _ClusterLeafs combine(_ClusterLeafs other) {
    return _ClusterLeafs(elements + other.elements);
  }
}
