import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:flutter/services.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import '/commons/globals.dart';
import '/commons/mapbox_utils.dart';
import '/widgets/home_controls.dart';
import '/widgets/home_sidebar.dart';
import '/models/question.dart';
import '/widgets/questions/question_input_view.dart';
import '/widgets/triangle_down.dart';
import '/api/stop_query_handler.dart';
import '/models/stop.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  final _mapCompleter = Completer<MapboxMapController>();

  final _styleCompleter = Completer<void>();

  late final MapboxMapController _mapController;

  final _stopQueryHandler = StopQueryHandler();

  final _sheetController = SheetController();

  static const double _initialSheetSize = 0.4;

  final _selectedMarker = ValueNotifier<Circle?>(null);

  Question? _selectedQuestion;

  late final Future<List<Question>> _questionCatalog;

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

    _questionCatalog = parseQuestions();
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
            // dispatch camera change events
            trackCameraPosition: true,
            compassEnabled: false,
            accessToken: MAPBOX_API_TOKEN,
            styleString: MAPBOX_STYLE_URL,
            myLocationEnabled: true,
            tiltGesturesEnabled: false,
            initialCameraPosition: CameraPosition(
              zoom: 15.0,
              target: LatLng(50.8261, 12.9278),
            ),
            onMapCreated: _mapCompleter.complete,
            onStyleLoadedCallback: _styleCompleter.complete,
            onMapClick: (Point point, LatLng location) => _closeSlidingSheet(),
            onCameraIdle: _onCameraIdle,
          ),
          FutureBuilder(
            future: _mapCompleter.future,
            builder: (BuildContext context, AsyncSnapshot<MapboxMapController> snapshot) {
              // only show controls when map creation finished
              return AnimatedSwitcher(
                duration: Duration(milliseconds: 1000),
                child: snapshot.hasData ?
                  HomeControls(
                    mapController: snapshot.data!,
                  ) :
                  Container(
                    color: Colors.white
                  )
              );
            }
          ),
          SlidingSheet(
            controller: _sheetController,
            addTopViewPaddingOnFullscreen: true,
            elevation: 8,
            // since the background color is overlaid by the individual builders/widgets background colors
            // this color is only visible as th top padding behind the navigation bar
            // thus it should match the header color
            color: Colors.white,
            cornerRadius: 15,
            cornerRadiusOnFullscreen: 0,
            liftOnScrollHeaderElevation: 8,
            closeOnBackButtonPressed: true,
            duration: const Duration(milliseconds: 300),
            snapSpec: const SnapSpec(
              snap: true,
              snappings: [_initialSheetSize, 1.0],
              positioning: SnapPositioning.relativeToAvailableSpace,
            ),
            headerBuilder: (context, state) {
              return _selectedQuestion == null ? SizedBox.shrink() : ColoredBox(
                color: const Color(0xfff7f7f7),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.fromLTRB(25, 15, 25, 15),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${_selectedMarker.value?.data?['name'] ?? 'Unknown'}"
                                  " - ${_selectedQuestion!.name}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black38,
                                  )
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  _selectedQuestion!.question,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              ],
                            )
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Icon(
                            Icons.info_outline_rounded,
                            color: Colors.black12,
                          )
                        ]
                      )
                    ),
                    const TriangleDown(
                      size: Size(10, 10),
                      color: Colors.white
                    ),
                  ]
                )
              );
            },
            builder: (context, state) {
              return _selectedQuestion == null ? SizedBox.shrink() : Container(
                color: const Color(0xfff7f7f7),
                padding: EdgeInsets.all(25),
                child: QuestionInputView.fromQuestionInput(_selectedQuestion!.input, onChange: null)
              );
            }
          )
        ]
      )),
    );
  }


  _initMap(MapboxMapController controller) async {
    // store reference to controller
    _mapController = controller;

    moveToUserLocation(mapController: controller);

    _mapController.onCircleTapped.add(_onCircleTap);

    _stopQueryHandler.stops.listen(_addStopsToMap);
  }

  void _onCameraIdle() async {
    // await _mapController and style loaded callback
    await _mapCompleter.future;
    await _styleCompleter.future;

    // only update/query until certain zoom level is reached
    if (_mapController.cameraPosition != null && _mapController.cameraPosition!.zoom >= 12) {
      var viewBBox = await _mapController.getVisibleRegion();
      _stopQueryHandler.update(viewBBox);
    }
  }

  _closeSlidingSheet() {
    // close bottom sheet if available
    _sheetController.hide();
    // deselect the current marker
    _deselectCurrentCircle();
  }

  void _onCircleTap(Circle circle) async {
    _deselectCurrentCircle();
    _selectCircle(circle);

    final questions = await _questionCatalog;
    _selectedQuestion = questions[Random().nextInt(questions.length)];

    _sheetController.rebuild();
    _sheetController.show();

    // move camera to circle
    // padding is not available for newLatLng()
    // therefore use newLatLngBounds as workaround
    final location = circle.options.geometry!;
    final paddingBottom = (MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top) * _initialSheetSize;
    moveToLocation(
        mapController: _mapController,
        location: location,
        paddingBottom: paddingBottom
    );
  }


  /// Deselect a given symbol on the map

  void _deselectCircle(Circle circle) {
    _mapController.updateCircle(circle, CircleOptions(
        circleStrokeColor: '#f0ca00',
        circleColor: '#f0ca00',
        circleRadius: 20,
    ));
    // unset variable
    _selectedMarker.value = null;
  }


  /// Deselect the last selected symbol on the map

  void _deselectCurrentCircle() {
    if (_selectedMarker.value != null) {
      _deselectCircle(_selectedMarker.value!);
    }
  }


  /// Select a given symbol on the map
  /// This pushes it to the _selectedMarker ValueNotifier and changes its icon

  void _selectCircle(Circle circle) {
    // ignore if the symbol is already selected
    if (_selectedMarker.value == circle) {
      return;
    }
    _mapController.updateCircle(circle, CircleOptions(
      circleColor: '#00cc7f',
      circleStrokeColor: '#00cc7f',
      circleRadius: 30,
    ));
    _selectedMarker.value = circle;
  }


  /// Add a given list of Stops as circles to the map

  void _addStopsToMap(Iterable<Stop> result) async {
    final data = <Map<String, String>>[];
    final circle = <CircleOptions>[];
    final dot = <CircleOptions>[];

    for (final stop in result) {
      dot.add(
          CircleOptions(
              circleRadius: 4,
              circleColor: '#00cc7f',
              circleOpacity: 1,
              geometry: stop.location)
      );
      circle.add(CircleOptions(
              circleRadius: 20,
              circleColor: '#f0ca00',
              circleOpacity: 0.2,
              circleStrokeColor: '#f0ca00',
              circleStrokeOpacity: 1,
              circleStrokeWidth: 5,
              geometry: stop.location)
      );
      data.add({
        "name": stop.name
      });
    }
    _mapController.addCircles(dot);
    _mapController.addCircles(circle, data);
  }


  Future<List<Question>> parseQuestions() async {
    final questionJsonData = await rootBundle.loadString("assets/questions/question_catalog.json");
    final questionJson = jsonDecode(questionJsonData).cast<Map<String, dynamic>>();
    return questionJson.map<Question>((question) => Question.fromJSON(question)).toList();
  }


  @override
  void dispose() {
    super.dispose();
    _mapController.dispose();
    _stopQueryHandler.dispose();
    _selectedMarker.dispose();
  }
}