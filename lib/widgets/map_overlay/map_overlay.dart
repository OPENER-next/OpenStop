import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_mvvm_architecture/base.dart';

import '/commons/osm_config.dart';
import '/commons/tile_layers.dart';
import '/l10n/app_localizations.g.dart';
import '/view_models/home_view_model.dart';
import 'attribution_text.dart';
import 'compass_button.dart';
import 'location_button.dart';
import 'zoom_button.dart';

/// Builds the action/control buttons and attribution text which overlay the map.

class MapOverlay extends ViewFragment<HomeViewModel> {
  final double buttonSpacing;

  const MapOverlay({
    super.key,
    this.buttonSpacing = 10.0,
  });

  @override
  Widget build(BuildContext context, viewModel) {
    final appLocale = AppLocalizations.of(context)!;
    return Padding(
      padding: MediaQuery.of(context).padding + EdgeInsets.all(buttonSpacing),
      child: Stack(
        children: [
          Align(
            alignment: AlignmentDirectional.topStart,
            child: FloatingActionButton.small(
              heroTag: null,
              onPressed: Scaffold.of(context).openDrawer,
              child: Icon(
                Icons.menu,
                semanticLabel: appLocale.semanticsNavigationMenu,
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: viewModel.mapRotation % 360 != 0
                  ? CompassButton(
                      rotation: viewModel.mapRotation,
                      isDegree: true,
                      onPressed: viewModel.resetRotation,
                    )
                  : null,
            ),
          ),
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: Semantics(
              container: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Semantics(
                      container: true,
                      sortKey: const OrdinalSortKey(2.0),
                      child: AttributionText(
                        alignment: TextAlign.left,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        children: [
                          AttributionTextPart(
                            AppLocalizations.of(context)!.osmAttributionText,
                            url: kOSMAttributionURL,
                          ),
                          AttributionTextPart(
                            kTileLayerPublicTransport.attributionText,
                            url: kTileLayerPublicTransport.attributionUrl,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Semantics(
                    container: true,
                    sortKey: const OrdinalSortKey(1.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      spacing: buttonSpacing,
                      children: [
                        LocationButton(
                          activeColor: Theme.of(context).colorScheme.primary,
                          activeIconColor: Theme.of(context).colorScheme.onPrimary,
                          color: Theme.of(context).colorScheme.primaryContainer,
                          iconColor: Theme.of(context).colorScheme.onPrimaryContainer,
                          active: viewModel.cameraIsFollowingLocation,
                          onPressed: viewModel.toggleLocationFollowing,
                        ),
                        ZoomButton(
                          onZoomInPressed: viewModel.zoomIn,
                          onZoomOutPressed: viewModel.zoomOut,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
