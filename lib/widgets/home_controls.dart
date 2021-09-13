import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:opener_next/commons/mapbox_utils.dart';
import 'package:opener_next/widgets/compass_button.dart';
import 'package:opener_next/widgets/zoom_button.dart';

/// Builds the action buttons which overlay the map.

class HomeControls extends StatefulWidget {
  final MapboxMapController mapController;
  final double buttonSpacing;

  const HomeControls({
    Key? key,
    required this.mapController,
    this.buttonSpacing = 10.0,
   }) : super(key: key);


  @override
  _HomeControlsState createState() => _HomeControlsState();
}


class _HomeControlsState extends State<HomeControls> {

  final ValueNotifier<bool> _isRotated = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();

    widget.mapController.addListener(() {
      _isRotated.value = widget.mapController.cameraPosition?.bearing != 0;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        0,
        widget.buttonSpacing + MediaQuery.of(context).padding.top,
        widget.buttonSpacing + MediaQuery.of(context).padding.right,
        widget.buttonSpacing + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FloatingActionButton.small(
            child: Icon(
              Icons.menu,
              color: Colors.black,
            ),
            onPressed: Scaffold.of(context).openDrawer,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              ValueListenableBuilder(
                valueListenable: _isRotated,
                builder: (BuildContext context, bool isRotated, Widget? compass) {
                  return AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: isRotated ? compass : const SizedBox.shrink()
                  );
                } ,
                child: CompassButton(
                  listenable: widget.mapController,
                  getRotation: () => -(widget.mapController.cameraPosition?.bearing ?? 0),
                  isDegree: true,
                  onPressed: _resetRotation,
                ),
              ),
              Spacer(),
              SizedBox (
                height: widget.buttonSpacing
              ),
              FloatingActionButton.small(
                child: Icon(
                  Icons.my_location,
                  color: Colors.black,
                ),
                onPressed: () => moveToUserLocation(mapController: widget.mapController),
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


  /// Zoom the map view

  void _zoomIn() {
    widget.mapController.animateCamera(CameraUpdate.zoomIn());
  }


  /// Zoom out of the map view

  void _zoomOut() {
    widget.mapController.animateCamera(CameraUpdate.zoomOut());
  }


  /// Reset map rotation

  void _resetRotation() {
    widget.mapController.animateCamera(CameraUpdate.bearingTo(0));
  }

}