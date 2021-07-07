import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

final String token = GlobalConfiguration().getValue("mapbox_api_token");
final String style = GlobalConfiguration().getValue("mapbox_style_url");

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OPENER next',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: Scaffold(
        body: MapboxMap(
          // Public Access Token
            accessToken: token,
            styleString: style,
            initialCameraPosition: CameraPosition(
              zoom: 15.0,
              target: LatLng(14.508, 46.048),
            ),

            // The onMapCreated callback should be used for everything related
            // to updating map components via the MapboxMapController instance
            onMapCreated: (MapboxMapController controller) async {
              // Acquire current location (returns the LatLng instance)
              final result = await acquireCurrentLocation();

              // You can either use the moveCamera or animateCamera, but the former
              // causes a sudden movement from the initial to 'new' camera position,
              // while animateCamera gives a smooth animated transition
              await controller.animateCamera(
                CameraUpdate.newLatLng(result),
              );

              // Add a circle denoting current user location
              await controller.addCircle(
                CircleOptions(
                  circleRadius: 8.0,
                  circleColor: '#006992',
                  circleOpacity: 0.8,

                  // YOU NEED TO PROVIDE THIS FIELD!!!
                  // Otherwise, you'll get a silent exception somewhere in the stack
                  // trace, but the parameter is never marked as @required, so you'll
                  // never know unless you check the stack trace
                  geometry: result,
                  draggable: false,
                ),
              );
            }
        ),
      ),
    );
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
  return LatLng(locationData.latitude, locationData.longitude);
}