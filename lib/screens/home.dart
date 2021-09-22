import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import '/commons/stream_debouncer.dart';
import '/widgets/stop_area_indicator.dart';
import '/widgets/question_sheet.dart';
import '/widgets/home_controls.dart';
import '/widgets/home_sidebar.dart';
import '/models/question.dart';
import '/widgets/loading_indicator.dart';
import '/api/stop_query_handler.dart';
import '/models/stop.dart';
import '/commons/map_utils.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();

  final _stopQueryHandler = StopQueryHandler();

  static const double _initialSheetSize = 0.4;

  final _selectedMarker = ValueNotifier<Stop?>(null);

  final _selectedQuestion = ValueNotifier<Question?>(null);

  late final Future<List<Question>> _questionCatalog = parseQuestions();

  final List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    // set system ui to fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // update native ui colors
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black.withOpacity(0.25),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black.withOpacity(0.25),
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    _mapController.mapEventStream.debounce<MapEvent>(Duration(milliseconds: 500)).listen((event) {
      if (_mapController.bounds != null && _mapController.zoom > 12) {
        _stopQueryHandler.update(_mapController.bounds!);
      }
    });

    _mapController.onReady.then((_) {
      // use timer as workaround because initial bounds are not applied in onReady yet
      Timer(Duration(seconds: 1), () {
        if (_mapController.bounds != null && _mapController.zoom > 12) {
          _stopQueryHandler.update(_mapController.bounds!);
        }
      });
    });

    _selectedQuestion.addListener(() {
      if (_selectedQuestion.value == null) _deselectCurrentStopArea();
    });
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
          StreamBuilder<Iterable<Stop>>(
            stream: _stopQueryHandler.stops,
            initialData: [],
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                for (var stop in snapshot.data!) {
                  _markers.add(Marker(
                    point: stop.location,
                    builder: (context) => GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => _onStopAreaTap(stop),
                      child: StopAreaIndicator()
                    )
                  ));
                }
              }

              // TODO: user location + tracking + clustering
              // TODO: fix  RangeError
              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  onTap: (position, location) => _selectedQuestion.value = null,
                  enableMultiFingerGestureRace: true,
                  center: LatLng(50.8261, 12.9278),
                  zoom: 15.0,
                  plugins: [
                    MarkerClusterPlugin(),
                  ],
                ),
                layers: [
                  TileLayerOptions(
                    urlTemplate: "https://osm-2.nearest.place/retina/{z}/{x}/{y}.png",
                    attributionAlignment: Alignment.bottomLeft,
                    attributionBuilder: (context) {
                      return Padding(
                        padding: EdgeInsets.only(left: 10, bottom: MediaQuery.of(context).padding.bottom + 10),
                        child: Text("© OpenStreetMap contributors")
                      );
                    },
                  ),
                  MarkerLayerOptions(
                    markers: _markers
                  )
                ],
              );
            }
          ),
          FutureBuilder(
            future: _mapController.onReady,
            builder: (BuildContext context, AsyncSnapshot<Null> snapshot) {
              // only show controls when map creation finished
              return AnimatedSwitcher(
                duration: Duration(milliseconds: 1000),
                child: snapshot.connectionState == ConnectionState.done
                  ? HomeControls(
                    mapController: _mapController
                  )
                  : Container(
                    color: Colors.white
                  )
              );
            }
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 15,
            right: 0.0,
            left: 0.0,
            child: ValueListenableBuilder<int>(
              builder: (BuildContext context, int value, Widget? child) =>
                AnimatedSwitcher(
                  switchInCurve: Curves.elasticOut,
                  switchOutCurve: Curves.elasticOut,
                  transitionBuilder: (Widget child, Animation<double> animation) =>
                    ScaleTransition(child: child, scale: animation),
                  duration: Duration(milliseconds: 500),
                  child: value > 0 ? child : const SizedBox.shrink()
                ),
              valueListenable: _stopQueryHandler.pendingQueryCount,
              child: LoadingIndicator()
            )
          ),
          QuestionSheet(
            question: _selectedQuestion,
            initialSheetSize: _initialSheetSize
          ),
        ]
      )),
    );
  }


  void _onStopAreaTap(Stop stop) async {
    _deselectCurrentStopArea();
    _selectStopArea(stop);

    final questions = await _questionCatalog;
    _selectedQuestion.value = questions[Random().nextInt(questions.length)];

    // move camera to circle
    // padding is not available for LatLng()
    // therefore use LatLngBounds as workaround
    final mediaQuery = MediaQuery.of(context);
    final paddingBottom =
      (mediaQuery.size.height - mediaQuery.padding.top - mediaQuery.padding.bottom) * _initialSheetSize;
    _mapController.animateToBounds(
      ticker: this,
      location: stop.location,
      padding: EdgeInsets.only(bottom: paddingBottom)
    );
  }


  /// Deselect a given symbol on the map

  void _deselectStopArea(Stop stop) {
    /*_mapController.updateCircle(circle, CircleOptions(
        circleStrokeColor: '#f0ca00',
        circleColor: '#f0ca00',
        circleRadius: 20,
    ));*/
    // unset variable
    _selectedMarker.value = null;
  }


  /// Deselect the last selected symbol on the map

  void _deselectCurrentStopArea() {
    if (_selectedMarker.value != null) {
      _deselectStopArea(_selectedMarker.value!);
    }
  }


  /// Select a given symbol on the map
  /// This pushes it to the _selectedMarker ValueNotifier and changes its icon

  void _selectStopArea(Stop stop) {
    // ignore if the symbol is already selected
    if (_selectedMarker.value == stop) {
      return;
    }
    /*_mapController.updateCircle(stop, CircleOptions(
      circleColor: '#00cc7f',
      circleStrokeColor: '#00cc7f',
      circleRadius: 30,
    ));*/
    _selectedMarker.value = stop;
  }


  Future<List<Question>> parseQuestions() async {
    final questionJsonData = await rootBundle.loadString("assets/questions/question_catalog.json");
    final questionJson = jsonDecode(questionJsonData).cast<Map<String, dynamic>>();
    return questionJson.map<Question>((question) => Question.fromJSON(question)).toList();
  }


  @override
  void dispose() {
    super.dispose();
    _stopQueryHandler.dispose();
    _selectedMarker.dispose();
  }
}