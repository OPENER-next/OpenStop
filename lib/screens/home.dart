import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:flutter/services.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import '/commons/globals.dart';
import '/commons/location-utils.dart';
import '/widgets/home-controlls.dart';
import '/widgets/home-sidebar.dart';

// dummy public transport stops
const stops = [
  LatLng(50.8260, 12.9278),
  LatLng(50.821, 12.9273),
  LatLng(50.8259, 12.9228),
  LatLng(50.8250, 12.9275),
  LatLng(50.8261, 12.9268)
];


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  final _mapCompleter = Completer<MapboxMapController>();

  late MapboxMapController _mapController;

  final _sheetController = SheetController();

  static const double _initialSheetSize = 0.4;

  final _markerStreamController = StreamController<Symbol>();

  Symbol? _selectedMarker;

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
    // wait for map creation to finish
    _mapCompleter.future.then(_initMap);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: HomeSidebar(),
      // use builder to get scaffold context
      body: Builder(builder: (context) => Stack(
        fit: StackFit.expand,
        children: <Widget>[
          MapboxMap(
            accessToken: MAPBOX_API_TOKEN,
            styleString: MAPBOX_STYLE_URL,
            compassEnabled: true,
            myLocationEnabled: true,
            tiltGesturesEnabled: false,
            initialCameraPosition: CameraPosition(
              zoom: 15.0,
              target: LatLng(50.8261, 12.9278),
            ),
            onMapCreated: _mapCompleter.complete,
            onStyleLoadedCallback: _addMapData,
            onMapClick: _onMapClick,
          ),
          FutureBuilder(
            future: _mapCompleter.future,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              // only show controls when map creation finished
              return AnimatedSwitcher(
                duration: Duration(milliseconds: 1000),
                child: snapshot.hasData ?
                  HomeControlls(
                    zoomIn: _zoomIn,
                    zoomOut: _zoomOut,
                    moveToUserLocation: _moveToUserLocation,
                    buttonStyle: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      onPrimary: Colors.orange,
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(10)
                    )
                  ) :
                  Container(
                    color: Colors.white.withOpacity(1)
                  )
              );
            }
          ),
          StreamBuilder(
            stream: _markerStreamController.stream,
            builder: (BuildContext context, AsyncSnapshot<Symbol> snapshot) {
              // return empty widget if no data is given
              if (!snapshot.hasData) {
                return SizedBox.shrink();
              }
              if (_sheetController.state?.isHidden == true) {
                _sheetController.show();
              }

              final name = snapshot.data != null ? snapshot.data!.id.toString() : 'name';

              return SlidingSheet(
                controller: _sheetController,
                addTopViewPaddingOnFullscreen: true,
                elevation: 8,
                cornerRadius: 25,
                cornerRadiusOnFullscreen: 0,
                liftOnScrollHeaderElevation: 8,
                closeOnBackButtonPressed: true,
                duration: const Duration(milliseconds: 300),
                snapSpec: const SnapSpec(
                  snap: true,
                  snappings: [_initialSheetSize, 1.0],
                  positioning: SnapPositioning.relativeToAvailableSpace,
                  // initialSnap: 0
                ),
                headerBuilder: (context, state) {
                  return Container(
                    color: Colors.white,
                    height: 50,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text(name)
                  );
                },
                builder: (context, state) {
                  return Container(
                    color: Colors.white,
                    height: 800,
                    child: Center(
                      child: Text('Content')
                    ),
                  );
                },
              );
            }
          )
        ]
      )),
    );
  }


  _initMap(MapboxMapController controller) async {
    // store reference to controler
    _mapController = controller;

    _moveToUserLocation();

    _mapController.onSymbolTapped.add(_onSymbolTap);
  }


  void _addMapData() async {
    // await _mapControllerbutton
    await _mapCompleter.future;

    _mapController.addSymbols(stops.map<SymbolOptions>((position) => SymbolOptions(
      geometry: position,
      iconImage: 'assets/symbols/bus_stop.png',
      iconSize: 0.5,
      iconAnchor: 'bottom'
    )).toList());
  }


  _onMapClick(Point point, LatLng location) async {
    // close bottom sheet if available
    _sheetController.hide();
    // deselect the current marker
    _deselectCurrentSymbol();
  }


  void _onSymbolTap(Symbol symbol) {
    _deselectCurrentSymbol();
    _selectSymbol(symbol);

    // move camera to symbol
    // padding is not available for newLatLng()
    // therefore use newLatLngBounds as workaround
    final location = symbol.options.geometry!;
    const extend =  LatLng(0.001, 0.001);
    final paddingBottom = (MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top) * _initialSheetSize;
    _mapController.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(southwest: location - extend, northeast: location + extend),
      bottom: paddingBottom
    ));
  }


  /**
   * Deselect a given symbol on the map
   */
  void _deselectSymbol(Symbol symbol) {
    _mapController.updateSymbol(symbol, SymbolOptions(
      iconImage: 'assets/symbols/bus_stop.png'
    ));
    // unset variable
    _selectedMarker = null;
  }


  /**
   * Deselect the last selected symbol on the map
   */
  void _deselectCurrentSymbol() {
    if (_selectedMarker != null) {
      _deselectSymbol(_selectedMarker!);
    }
  }


  /**
   * Select a given symbol on the map
   * This pushes it to the _markerStreamController and changes its icon
   */
  void _selectSymbol(Symbol symbol) {
    // ignore if the symbol is already selected
    if (_selectedMarker == symbol) {
      return;
    }
    _mapController.updateSymbol(symbol, SymbolOptions(
      iconImage: 'assets/symbols/bus_stop_selected.png'
    ));
    _markerStreamController.add(symbol);
    _selectedMarker = symbol;
  }


  /**
   * Zoom the map view
   */
  void _zoomIn() {
    _mapController.animateCamera(CameraUpdate.zoomIn());
  }


  /**
   * Zoom out of the map view
   */
  void _zoomOut() {
    _mapController.animateCamera(CameraUpdate.zoomOut());
  }


  /**
   * Update the current map view position to a given location
   */
  Future<void> _moveTo(LatLng location) async {
    await _mapController.animateCamera(CameraUpdate.newLatLng(location));
  }


  /**
   * Acquire current location and update map view position
   * Returns false if the location couldn't be acquired otherwise true
   */
  Future<bool> _moveToUserLocation() async {
    final location = await acquireCurrentLocation();
    if (location != null) {
      await _moveTo(location);
    }
    return location != null;
  }
}