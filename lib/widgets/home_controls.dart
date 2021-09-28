import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:opener_next/helpers/camera_tracker.dart';
import '/widgets/location_button.dart';
import '/widgets/map_layer_switcher.dart';
import '/commons/map_utils.dart';
import '/widgets/compass_button.dart';
import '/widgets/zoom_button.dart';

/// Builds the action buttons which overlay the map.

class HomeControls extends StatefulWidget {
  final MapController mapController;
  final ValueNotifier<String> tileProvider;
  final CameraTracker cameraTracker;
  final double buttonSpacing;

  const HomeControls({
    Key? key,
    required this.mapController,
    required this.cameraTracker,
    required this.tileProvider,
    this.buttonSpacing = 10.0,
   }) : super(key: key);


  @override
  _HomeControlsState createState() => _HomeControlsState();
}


class _HomeControlsState extends State<HomeControls> with TickerProviderStateMixin {

  final ValueNotifier<bool> _isRotatedNotifier = ValueNotifier<bool>(false);

  final ValueNotifier<double> _rotationNotifier = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();

    widget.mapController.mapEventStream.listen((event) {
      _rotationNotifier.value = widget.mapController.rotation;
      _isRotatedNotifier.value = widget.mapController.rotation != 0;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        widget.buttonSpacing + MediaQuery.of(context).padding.left,
        widget.buttonSpacing + MediaQuery.of(context).padding.top,
        widget.buttonSpacing + MediaQuery.of(context).padding.right,
        widget.buttonSpacing + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FloatingActionButton.small(
                child: Icon(
                  Icons.menu,
                  color: Colors.black,
                ),
                onPressed: Scaffold.of(context).openDrawer,
              ),
              Spacer(),
              MapLayerSwitcher(
                entries: [
                  MapLayerSwitcherEntry(key: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
                    icon: Icons.satellite_rounded, label: "Satellite"
                  ),
                  MapLayerSwitcherEntry(key: "https://osm-2.nearest.place/retina/{z}/{x}/{y}.png",
                    icon: Icons.map_rounded, label: "Map"
                  ),
                  // TODO: We really need this!! Showing where the tram and bus routes are is crucial for our App.
                  // Thunderforest requires an API key unfortunately
                  MapLayerSwitcherEntry(key: "https://{s}.tile.thunderforest.com/transport/{z}/{x}/{y}.png",
                    icon: Icons.map_rounded, label: "Thunderforest.Transport"
                  ),
                ],
                active: widget.tileProvider.value,
                onSelection: _changeTileProvider,
              ),
            ]
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              ValueListenableBuilder(
                valueListenable: _isRotatedNotifier,
                builder: (BuildContext context, bool isRotated, Widget? compass) {
                  return AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: isRotated ? compass : const SizedBox.shrink()
                  );
                } ,
                child: CompassButton(
                  listenable: _rotationNotifier,
                  getRotation: () => widget.mapController.rotation,
                  isDegree: true,
                  onPressed: _resetRotation,
                ),
              ),
              Spacer(),
              SizedBox (
                height: widget.buttonSpacing
              ),
              LocationButton(
                cameraTracker: widget.cameraTracker,
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
      )
    );
  }


  /// Zoom the map view.

  void _zoomIn() {
    // round zoom level so zoom will always stick to integer levels
    widget.mapController.animateTo(ticker: this, zoom: widget.mapController.zoom.roundToDouble() + 1);
  }


  /// Zoom out of the map view.

  void _zoomOut() {
    // round zoom level so zoom will always stick to integer levels
    widget.mapController.animateTo(ticker: this, zoom: widget.mapController.zoom.roundToDouble() - 1);
  }


  /// Reset the map rotation.

  void _resetRotation() {
    widget.mapController.animateTo(ticker: this, rotation: 0);
  }


  /// Update the ValueNotifier that contains the url from which tiles are fetched.

  void _changeTileProvider(MapLayerSwitcherEntry) {
    widget.tileProvider.value = MapLayerSwitcherEntry.key;
  }
}