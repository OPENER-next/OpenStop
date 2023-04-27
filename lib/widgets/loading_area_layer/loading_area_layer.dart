import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'ripple_indicator.dart';
import 'map_layer.dart';

/// Layer to show ripple animations for geo circles and automatically remove them when expired.

class LoadingAreaLayer extends StatefulWidget {

  final Iterable<Circle> areas;

  const LoadingAreaLayer({
    required this.areas,
    super.key,
  });

  @override
  State<LoadingAreaLayer> createState() => _LoadingAreaLayerState();
}

class _LoadingAreaLayerState extends State<LoadingAreaLayer> {
  var _loadingAreas = <Circle, MapLayerPositioned>{};

  final _expiredAreas = <Circle, MapLayerPositioned>{};

  @override
  void didUpdateWidget(covariant LoadingAreaLayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newLoadingAreas = <Circle, MapLayerPositioned>{};
    for (final area in widget.areas) {
      _expiredAreas.remove(area);
      newLoadingAreas[area] = _buildChild(area);
    }

    final newExpiredEntries = _loadingAreas.keys
      .where((area) => !newLoadingAreas.containsKey(area))
      .map((area) => MapEntry(area, _buildChild(area, end: true)));

    _expiredAreas.addEntries(newExpiredEntries);
    _loadingAreas = newLoadingAreas;
  }

  MapLayerPositioned _buildChild(Circle area, { bool end = false }) {
    return MapLayerPositioned(
      key: ValueKey(area),
      position: area.center,
      size: Size.fromRadius(area.radius),
      child: RippleIndicator(
        end: end,
        onEnd: !end ? null : () {
          setState(() {
            // remove widget if animation ended
            _expiredAreas.remove(area);
          });
        },
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MapLayer(
      children: _loadingAreas.values.followedBy(_expiredAreas.values).toList(),
    );
  }
}
