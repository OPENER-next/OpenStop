
import 'package:flutter/material.dart';

/// Builds the action buttons which overlay the map.

class HomeControls extends StatelessWidget {
  final double buttonSpacing;
  final double buttonIconSize;
  final ButtonStyle buttonStyle;

  final void Function() zoomIn;
  final void Function() zoomOut;
  final void Function() moveToUserLocation;


  const HomeControls({
    Key? key,
    required this.buttonStyle,
    required this.zoomIn,
    required this.zoomOut,
    required this.moveToUserLocation,
    this.buttonSpacing = 10.0,
    this.buttonIconSize = 25.0
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        0,
        buttonSpacing + MediaQuery.of(context).padding.top,
        0,
        buttonSpacing + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ElevatedButton(
            style: buttonStyle,
            child: Icon(
              Icons.menu,
              size: buttonIconSize,
              color: Colors.black,
            ),
            onPressed: Scaffold.of(context).openDrawer,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              ElevatedButton(
                style: buttonStyle,
                child: Icon(
                  Icons.my_location,
                  size: buttonIconSize,
                  color: Colors.black,
                ),
                onPressed: moveToUserLocation,
              ),
              SizedBox (
                height: buttonSpacing
              ),
              ElevatedButton(
                style: buttonStyle,
                child: Icon(
                  Icons.add,
                  size: buttonIconSize,
                  color: Colors.black,
                ),
                onPressed: zoomIn,
              ),
              SizedBox (
                height: buttonSpacing
              ),
              ElevatedButton(
                style: buttonStyle,
                child: Icon(
                  Icons.remove,
                  size: buttonIconSize,
                  color: Colors.black,
                ),
                onPressed: zoomOut,
              ),
            ]
          )
        ],
      )
    );
  }
}