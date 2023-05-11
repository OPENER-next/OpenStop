import 'package:flutter/material.dart';
import 'package:flutter_mvvm_architecture/base.dart';

import '/view_models/home_view_model.dart';
import '/commons/tile_layers.dart';
import '/commons/osm_config.dart' as osm_config;
import 'location_button.dart';
import 'map_layer_switcher.dart';
import 'compass_button.dart';
import 'zoom_button.dart';
import 'loading_indicator.dart';
import 'credit_text.dart';


/// Builds the action/control buttons and attribution text which overlay the map.

class MapOverlay extends ViewFragment<HomeViewModel> {
  final double buttonSpacing;

  const MapOverlay({
    Key? key,
    this.buttonSpacing = 10.0,
   }) : super(key: key);

  @override
  Widget build(BuildContext context, viewModel) {
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
              padding: MediaQuery.of(context).padding + EdgeInsets.all(buttonSpacing),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: LoadingIndicator(
                      active: viewModel.isLoadingStopAreas,
                    ),
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
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: viewModel.mapRotation % 360 != 0
                        ? CompassButton(
                          rotation: viewModel.mapRotation,
                          isDegree: true,
                          onPressed: viewModel.resetRotation,
                        )
                        : null
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        MapLayerSwitcher(
                          entries: tileLayers.entries.map((entry) =>
                            MapLayerSwitcherEntry(
                              id: entry.key,
                              icon: entry.value.icon ?? Icons.map_rounded,
                              label: entry.value.name,
                            ),
                          ).toList(),
                          active: viewModel.tileLayerId,
                          onSelection: (TileLayerId v) => viewModel.updateTileProvider([v]),
                        ),
                        Expanded(
                          child: CreditText(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            children: [
                              const CreditTextPart(
                                osm_config.osmCreditsText,
                                url: osm_config.osmCreditsURL,
                              ),
                              CreditTextPart(
                                viewModel.tileLayer.creditsText,
                                url: viewModel.tileLayer.creditsUrl,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            LocationButton(
                              activeColor: Theme.of(context).colorScheme.primary,
                              activeIconColor: Theme.of(context).colorScheme.onPrimary,
                              color: Theme.of(context).colorScheme.primaryContainer,
                              iconColor: Theme.of(context).colorScheme.onPrimaryContainer,
                              active: viewModel.cameraIsFollowingLocation,
                              onPressed: viewModel.toggleLocationFollowing,
                            ),
                            SizedBox (
                              height: buttonSpacing,
                            ),
                            ZoomButton(
                              onZoomInPressed: viewModel.zoomIn,
                              onZoomOutPressed: viewModel.zoomOut,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
