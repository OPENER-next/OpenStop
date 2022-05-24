import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

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
  _MapOverlayState createState() => _MapOverlayState();
}


class _MapOverlayState extends State<MapOverlay> with TickerProviderStateMixin {

  final ValueNotifier<bool> _isRotatedNotifier = ValueNotifier<bool>(false);

  final ValueNotifier<double> _rotationNotifier = ValueNotifier<double>(0);

  late final mapController = context.read<MapController>();

  @override
  void initState() {
    super.initState();

    mapController.mapEventStream.listen((event) {
      _rotationNotifier.value = mapController.rotation;
      _isRotatedNotifier.value = mapController.rotation != 0;
    });
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
                    child: ValueListenableBuilder(
                      valueListenable: _isRotatedNotifier,
                      builder: (BuildContext context, bool isRotated, Widget? compass) {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: isRotated ? compass : const SizedBox.shrink()
                        );
                      } ,
                      child: CompassButton(
                        listenable: _rotationNotifier,
                        getRotation: () => mapController.rotation,
                        isDegree: true,
                        onPressed: _resetRotation,
                      ),
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
                            Selector<UserLocationProvider, bool>(
                              selector: (_, p1) => p1.isFollowingLocation,
                              builder: (context, isFollowingLocation, child) => LocationButton(
                                activeColor: Theme.of(context).colorScheme.primary,
                                activeIconColor: Theme.of(context).colorScheme.onPrimary,
                                color: Theme.of(context).colorScheme.secondary,
                                iconColor: Theme.of(context).colorScheme.onSecondary,
                                active: isFollowingLocation,
                                onPressed: _toggleLocationFollowing
                              )
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
    // round zoom level so zoom will always stick to integer levels
    mapController.animateTo(ticker: this, zoom: mapController.zoom.roundToDouble() + 1);
  }


  /// Zoom out of the map view.

  void _zoomOut() {
    // round zoom level so zoom will always stick to integer levels
    mapController.animateTo(ticker: this, zoom: mapController.zoom.roundToDouble() - 1);
  }


  /// Reset the map rotation.

  void _resetRotation() {
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
