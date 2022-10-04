import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

import '/utils/stream_utils.dart';
import '/view_models/user_location_provider.dart';
import '/view_models/preferences_provider.dart';
import '/view_models/stop_areas_provider.dart';
import '/commons/tile_layers.dart';
import '/commons/osm_config.dart' as osm_config;
import '/utils/map_utils.dart';
import 'location_button.dart';
import 'map_layer_switcher.dart';
import 'compass_button.dart';
import 'zoom_button.dart';
import 'loading_indicator.dart';
import 'credit_text.dart';


/// Builds the action/control buttons and attribution text which overlay the map.

class MapOverlay extends StatefulWidget {
  final double buttonSpacing;

  const MapOverlay({
    Key? key,
    this.buttonSpacing = 10.0,
   }) : super(key: key);


  @override
  State<MapOverlay> createState() => _MapOverlayState();
}


class _MapOverlayState extends State<MapOverlay> with TickerProviderStateMixin {

  late final Stream<double> _rotationStream;

  @override
  void initState() {
    super.initState();

    final mapController = context.read<MapController>();

    _rotationStream = mapController.mapEventStream
      .map((event) => mapController.rotation)
      // used to filter notifications that do not alter the rotation
      .transform(ComparePreviousTransformer(
        (previous, current) => previous != current),
      );
  }


  @override
  Widget build(BuildContext context) {
    // This allows other widgets which make use of the OverlayEntry widget to display
    // widgets above these widgets without overlaying every widget like the drawer.
    // This is basically an in between layer, while widgets like dialogs or drawers
    // are rendered on the top layer/Overlay widget.
    // The map layer switcher makes use of this.
    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) {
            return Padding(
              padding: MediaQuery.of(context).padding + EdgeInsets.all(widget.buttonSpacing),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Consumer<StopAreasProvider>(
                      builder: (context, stopAreasProvider, child) {
                        return ValueListenableBuilder<bool>(
                          valueListenable: stopAreasProvider.isLoading,
                          builder: (context, value, child) => LoadingIndicator(
                            active: value,
                          ),
                        );
                      }
                    )
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: FloatingActionButton.small(
                      heroTag: null,
                      onPressed: Scaffold.of(context).openDrawer,
                      child: const Icon(
                        Icons.menu,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: StreamBuilder<double>(
                      stream: _rotationStream,
                      initialData: context.read<MapController>().rotation,
                      builder: (BuildContext context, snapshot) {
                        final rotation = snapshot.requireData;
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: rotation % 360 != 0
                            ? CompassButton(
                              rotation: rotation,
                              isDegree: true,
                              onPressed: _resetRotation,
                            )
                            : null
                        );
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Selector<PreferencesProvider, TileLayerId>(
                          selector: (context, value) => value.tileLayerId,
                          builder: (context, tileLayerId, child) {
                            return MapLayerSwitcher(
                              entries: tileLayers.entries.map((entry) =>
                                MapLayerSwitcherEntry(
                                  id: entry.key,
                                  icon: entry.value.icon ?? Icons.map_rounded,
                                  label: entry.value.name
                                )
                              ).toList(),
                              active: tileLayerId,
                              onSelection: _updateTileProvider,
                            );
                          }
                        ),
                        Expanded(
                          child: Selector<PreferencesProvider, TileLayerId>(
                            selector: (context, value) => value.tileLayerId,
                            builder: (context, tileLayerId, child) {
                              return CreditText(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10
                                ),
                                children: [
                                  const CreditTextPart(
                                    osm_config.osmCreditsText,
                                    url: osm_config.osmCreditsURL
                                  ),
                                  CreditTextPart(
                                    tileLayers[tileLayerId]?.creditsText ?? 'Unknown',
                                    url: tileLayers[tileLayerId]?.creditsUrl
                                  )
                                ],
                              );
                            }
                          )
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            LocationButton(
                                activeColor: Theme.of(context).colorScheme.primary,
                                activeIconColor: Theme.of(context).colorScheme.onPrimary,
                                color: Theme.of(context).colorScheme.secondary,
                                iconColor: Theme.of(context).colorScheme.onSecondary,
                                // Used context.select instead of Selector widget because of: https://github.com/rrousselGit/provider/issues/339
                                active: context.select<UserLocationProvider, bool>((provider) => provider.isFollowingLocation),
                                onPressed: _toggleLocationFollowing
                            ),
                            SizedBox (
                              height: widget.buttonSpacing
                            ),
                            ZoomButton(
                              onZoomInPressed: _zoomIn,
                              onZoomOutPressed: _zoomOut,
                            )
                          ]
                        )
                      ],
                    ),
                  )
                ]
              )
            );
          }
        )
      ]
    );
  }


  /// Zoom the map view.

  void _zoomIn() {
    final mapController = context.read<MapController>();
    // round zoom level so zoom will always stick to integer levels
    mapController.animateTo(ticker: this, zoom: mapController.zoom.roundToDouble() + 1);
  }


  /// Zoom out of the map view.

  void _zoomOut() {
    final mapController = context.read<MapController>();
    // round zoom level so zoom will always stick to integer levels
    mapController.animateTo(ticker: this, zoom: mapController.zoom.roundToDouble() - 1);
  }


  /// Reset the map rotation.

  void _resetRotation() {
    final mapController = context.read<MapController>();
    mapController.animateTo(ticker: this, rotation: 0);
  }


  /// Activate or deactivate location following depending on its current state.

  void _toggleLocationFollowing() {
    final userLocationProvider = context.read<UserLocationProvider>();
    // if location tracking is disabled always enable tracking and following
    if (userLocationProvider.state == LocationTrackingState.disabled) {
      userLocationProvider.shouldFollowLocation = true;
      userLocationProvider.startLocationTracking();
    }
    else if (userLocationProvider.state == LocationTrackingState.enabled) {
      userLocationProvider.shouldFollowLocation = !userLocationProvider.shouldFollowLocation;
    }
  }


  /// Store and apply selected tile layer id.

  // ignore: use_setters_to_change_properties
  void _updateTileProvider(TileLayerId newTileLayerId) {
    context.read<PreferencesProvider>().tileLayerId = newTileLayerId;
  }
}
