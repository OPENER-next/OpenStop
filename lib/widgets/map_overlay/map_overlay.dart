import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_mvvm_architecture/base.dart';

import '/commons/tile_layers.dart';
import '/view_models/home_view_model.dart';
import '/commons/osm_config.dart' as osm_config;
import 'location_button.dart';
import 'compass_button.dart';
import 'zoom_button.dart';
import 'credit_text.dart';
import 'shimmer.dart';


/// Builds the action/control buttons and attribution text which overlay the map.

class MapOverlay extends ViewFragment<HomeViewModel> {
  final double buttonSpacing;

  const MapOverlay({
    Key? key,
    this.buttonSpacing = 10.0,
   }) : super(key: key);

  @override
  Widget build(BuildContext context, viewModel) {
    return Stack(
      children: [ 
        Positioned.fill(
          child: Shimmer(
            active: viewModel.isLoadingStopAreas,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
            child: Container(
              color: Colors.transparent,
              width: MediaQuery.of(context).size.width, 
              height: MediaQuery.of(context).size.height,
            ),
          ),
        ),
        Padding(
          padding: MediaQuery.of(context).padding + EdgeInsets.all(buttonSpacing),
          child: Stack(
            children: [
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
                    Expanded(
                      child: CreditText(
                        alignment: TextAlign.left,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        children: [
                          CreditTextPart(
                            AppLocalizations.of(context)!.osmCreditsText,
                            url: osm_config.osmCreditsURL,
                          ),
                          CreditTextPart(
                            kTileLayerPublicTransport.creditsText,
                            url: kTileLayerPublicTransport.creditsUrl,
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
        ),
      ] 
    ); 
  }
}
