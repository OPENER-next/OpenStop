import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:flutter/services.dart';
import 'package:opener_next/widgets/sidebar.dart';
import '/commons/globals.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  MapboxMapController _mapController;

  @override
  void initState() {
    super.initState();
    // update native ui colors
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      // TODO: revisit this when https://github.com/flutter/flutter/pull/81303 lands
      statusBarColor: Colors.black.withOpacity(0.25),
      systemNavigationBarColor: Colors.black.withOpacity(0.25),
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: Sidebar(),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          MapboxMap(
            accessToken: MAPBOX_API_TOKEN,
            styleString: MAPBOX_STYLE_URL,
            compassEnabled: true,
            myLocationEnabled: true,
            initialCameraPosition: CameraPosition(
              zoom: 15.0,
              target: LatLng(14.508, 46.048),
            ),
            onMapCreated: _handleMapCreation
          ),
          _buildActionButtons(context)
        ]
      )
    );
  }


  /**
   * Builds the buttons which overlay the map.
   */
  Widget _buildActionButtons(BuildContext context) {
    final buttonSpacing = 10.0;
    final buttonIconSize = 25.0;
    final buttonStyle = ElevatedButton.styleFrom(
      primary: Colors.white,
      onPrimary: Colors.orange,
      shape: CircleBorder(),
      padding: EdgeInsets.all(10)
    );
    // use builder to get scaffold context
    return Builder(builder: (context) =>
      Positioned(
        // add system bottom bar height
        bottom: buttonSpacing + MediaQuery.of(context).padding.bottom,
        right: 0,
        // add status bar height
        top: buttonSpacing + MediaQuery.of(context).padding.top,
        left: 0,
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
                    Icons.add,
                    size: buttonIconSize,
                    color: Colors.black,
                  ),
                  onPressed: _zoomIn,
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
                  onPressed: _zoomOut,
                ),
              ]
            )
          ],
        )
      )
    );
  }


  _handleMapCreation(MapboxMapController controller) async {
    // store reference to controler
    _mapController = controller;
    // acquire current location and update map view position
    final result = await acquireCurrentLocation();
    if (result != null) {
      await _mapController.animateCamera(
        CameraUpdate.newLatLng(result),
      );
    }
  }


  void _zoomIn() {
    _mapController.animateCamera(CameraUpdate.zoomIn());
  }


  void _zoomOut() {
    _mapController.animateCamera(CameraUpdate.zoomOut());
  }
}


Future<LatLng> acquireCurrentLocation() async {
  // Initializes the plugin and starts listening for potential platform events
  Location location = new Location();

  // Whether or not the location service is enabled
  bool serviceEnabled;

  // Status of a permission request to use location services
  PermissionStatus permissionGranted;

  // Check if the location service is enabled, and if not, then request it. In
  // case the user refuses to do it, return immediately with a null result
  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      return null;
    }
  }

  // Check for location permissions; similar to the workflow in Android apps,
  // so check whether the permissions is granted, if not, first you need to
  // request it, and then read the result of the request, and only proceed if
  // the permission was granted by the user
  permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) {
      return null;
    }
  }

  // Gets the current location of the user
  final locationData = await location.getLocation();
  if (locationData.latitude != null && locationData.longitude != null) {
    return LatLng(locationData.latitude, locationData.longitude);
  }
}