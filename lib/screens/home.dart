import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:animated_location_indicator/animated_location_indicator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '/view_models/map_view_model.dart';
import '/helpers/camera_tracker.dart';
import '/commons/stream_debouncer.dart';
import '/widgets/map_layer/stop_area_layer.dart';
import '/widgets/question_sheet.dart';
import '/widgets/home_controls.dart';
import '/widgets/home_sidebar.dart';
import '/models/question.dart';
import '/widgets/loading_indicator.dart';
import '/api/stop_query_handler.dart';
import '/models/stop_area.dart';
import '/commons/map_utils.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  static const double _initialSheetSize = 0.4;

  static const double _stopAreaDiameter = 100;

  final MapController _mapController = MapController();

  final _stopQueryHandler = StopQueryHandler();

  final _selectedMarker = ValueNotifier<StopArea?>(null);

  final _selectedQuestion = ValueNotifier<Question?>(null);

  late final _cameraTracker = CameraTracker(
    ticker: this,
    mapController: _mapController
  );

  late final Future<List<Question>> _questionCatalog = parseQuestions();

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

    // query stops on map interactions
    _mapController.mapEventStream.debounce<MapEvent>(Duration(milliseconds: 500)).listen((event) {
      if (_mapController.bounds != null && _mapController.zoom > 12) {
        _stopQueryHandler.update(_mapController.bounds!);
      }
    });

    _mapController.onReady.then((_) {
      // use post frame callback because initial bounds are not applied in onReady yet
      SchedulerBinding.instance?.addPostFrameCallback((duration) {
        // move to user location and start camera tracking on app start
        // this will also trigger the first query of stops, but only if the user enabled the location service
        _cameraTracker.startTacking(initialZoom: 15);
      });
    });

    _selectedQuestion.addListener(() {
      if (_selectedQuestion.value == null) _deselectCurrentStopArea();
    });
  }


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => _mapController),
        ListenableProvider.value(value: _cameraTracker),
        ListenableProvider.value(value: MapViewModel(
          urlTemplate: "https://osm-2.nearest.place/retina/{z}/{x}/{y}.png"
        )),
      ],
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        drawer: HomeSidebar(),
        // use builder to get scaffold context
        body: Builder(builder: (context) =>
          Stack(
            fit: StackFit.expand,
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  onTap: (position, location) => _selectedQuestion.value = null,
                  enableMultiFingerGestureRace: true,
                  center: LatLng(50.8144951, 12.9295576),
                  zoom: 15.0,
                ),
                children: [
                  Consumer<MapViewModel>(
                    builder: (context, value, child) {
                      return TileLayerWidget(
                        options: TileLayerOptions(
                          overrideTilesWhenUrlChanges: true,
                          urlTemplate: value.urlTemplate,
                          minZoom: value.minZoom,
                          maxZoom: value.maxZoom,
                          tileProvider: NetworkTileProvider(),
                        ),
                      );
                    }
                  ),
                  StopAreaLayer(
                    stopStream: _stopQueryHandler.stops,
                    onStopAreaTap: _onStopAreaTap,
                  ),
                  AnimatedLocationLayerWidget(
                    options: AnimatedLocationOptions()
                  )
                ],
                nonRotatedChildren: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 10),
                      child: Text(
                        "© OpenStreetMap contributors",
                        style: TextStyle(
                          fontSize: 10
                        ),
                      )
                    )
                  ),
                  FutureBuilder(
                    future: _mapController.onReady,
                    builder: (BuildContext context, AsyncSnapshot<Null> snapshot) {
                      // only show controls when map creation finished
                      return AnimatedSwitcher(
                        duration: Duration(milliseconds: 1000),
                        child: snapshot.connectionState == ConnectionState.done
                          ? HomeControls()
                          : Container(
                            color: Colors.white
                          )
                      );
                    }
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 15),
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
                    )
                  ),
                ],
              ),
              // place sheet on extra stack above map so touch events won't pass through
              QuestionSheet(
                question: _selectedQuestion,
                initialSheetSize: _initialSheetSize
              ),
            ],
          )
        ),
      )
    );
  }


  void _onStopAreaTap(StopArea stopArea) async {
    _deselectCurrentStopArea();
    _selectStopArea(stopArea);

    final questions = await _questionCatalog;
    _selectedQuestion.value = questions[Random().nextInt(questions.length)];

    // move camera to stop area and include default sheet size as bottom padding
    final mediaQuery = MediaQuery.of(context);
    final paddingBottom =
      (mediaQuery.size.height - mediaQuery.padding.top - mediaQuery.padding.bottom) * _initialSheetSize;

    _mapController.animateToCircle(
      ticker: this,
      center: stopArea.center,
      radius: _stopAreaDiameter / 2 + stopArea.diameter / 2,
      padding: EdgeInsets.only(bottom: paddingBottom)
    );
  }


  /// Deselect a given symbol on the map

  void _deselectStopArea(StopArea stopArea) {
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

  void _selectStopArea(StopArea stopArea) {
    // ignore if the symbol is already selected
    if (_selectedMarker.value == stopArea) {
      return;
    }
    _selectedMarker.value = stopArea;
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