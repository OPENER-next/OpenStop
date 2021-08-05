import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:opener_next/commons/location_utils.dart';
import 'package:opener_next/widgets/compass_button.dart';

/// Builds the action buttons which overlay the map.

class HomeControls extends StatefulWidget {
  final MapboxMapController mapController;
  final double buttonSpacing;
  final double buttonIconSize;
  final ButtonStyle buttonStyle;

  const HomeControls({
    Key? key,
    required this.mapController,
    required this.buttonStyle,
    this.buttonSpacing = 10.0,
    this.buttonIconSize = 25.0
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
        0,
        widget.buttonSpacing + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ElevatedButton(
            style: widget.buttonStyle,
            child: Icon(
              Icons.menu,
              size: widget.buttonIconSize,
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
                  controller: widget.mapController,
                  onPressed: _resetRotation,
                  style: widget.buttonStyle
                ),
              ),
              Spacer(),
              SizedBox (
                height: widget.buttonSpacing
              ),
              ElevatedButton(
                style: widget.buttonStyle,
                child: Icon(
                  Icons.my_location,
                  size: widget.buttonIconSize,
                  color: Colors.black,
                ),
                onPressed: _moveToUserLocation,
              ),
              SizedBox (
                height: widget.buttonSpacing
              ),
              ElevatedButton(
                style: widget.buttonStyle,
                child: Icon(
                  Icons.add,
                  size: widget.buttonIconSize,
                  color: Colors.black,
                ),
                onPressed: _zoomIn,
              ),
              SizedBox (
                height: widget.buttonSpacing
              ),
              ElevatedButton(
                style: widget.buttonStyle,
                child: Icon(
                  Icons.remove,
                  size: widget.buttonIconSize,
                  color: Colors.black,
                ),
                onPressed: _zoomOut,
              ),
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


  /// Moves the camera to the current user location

  Future<bool> _moveToUserLocation() async {
    final location = await acquireCurrentLocation();
    if (location != null) {
      await widget.mapController.animateCamera(CameraUpdate.newLatLng(location));
    }
    return location != null;
  }
}