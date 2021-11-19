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
import 'package:osm_api/osm_api.dart';
import 'package:provider/provider.dart';
import '/view_models/osm_elements_provider.dart';
import '/view_models/map_view_model.dart';
import '/helpers/camera_tracker.dart';
import '/commons/stream_debouncer.dart';
import '/widgets/map_layer/stop_area_layer.dart';
import '/widgets/question_dialog/question_dialog.dart';
import '/widgets/home_controls.dart';
import '/widgets/home_sidebar.dart';
import '/models/question.dart';
import '/widgets/loading_indicator.dart';
import '/widgets/map_layer/osm_element_layer.dart';
import '/view_models/stop_areas_provider.dart';
import '/models/stop_area.dart';
import '/commons/map_utils.dart';
import '/commons/geo_utils.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  static const double _stopAreaDiameter = 100;

  final MapController _mapController = MapController();

  final _stopAreasProvider = StopAreasProvider(
    stopAreaDiameter: _stopAreaDiameter
  );

  final _selectedQuestion = ValueNotifier<Question?>(null);

  late final _cameraTracker = CameraTracker(
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
        _stopAreasProvider.loadStopAreas(_mapController.bounds!);
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
  }


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => _mapController),
        ListenableProvider.value(value: _cameraTracker),
        ListenableProvider.value(value: _stopAreasProvider),
        ListenableProvider.value(value: OSMElementProvider(
          stopAreaDiameter: _stopAreaDiameter
        )),
        ListenableProvider.value(value: MapViewModel(
          urlTemplate: "https://osm-2.nearest.place/retina/{z}/{x}/{y}.png"
        )),
      ],
      child: Scaffold(
        drawer: HomeSidebar(),
        // use builder to get scaffold context
        body: Builder(builder: (context) =>
          Stack(
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
                  Consumer2<StopAreasProvider, OSMElementProvider>(
                    builder: (context, stopAreaProvider, osmElementProvider, child) {
                    return StopAreaLayer(
                      stopAreas: stopAreaProvider.stopAreas,
                      loadingStopAreas: osmElementProvider.loadingStopAreas,
                      stopAreaDiameter: stopAreaProvider.stopAreaDiameter,
                      onStopAreaTap: (stopArea) => _onStopAreaTap(stopArea, context),
                    );
                  }),
                  Consumer<OSMElementProvider>(
                    builder: (context, osmElementProvider, child) {
                    return OsmElementLayer(
                      onOsmElementTap: _onOsmElementTap,
                      osmElements: osmElementProvider.loadedOsmElements
                    );
                  }),
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
                      child: ValueListenableBuilder<bool>(
                        valueListenable: context.read<StopAreasProvider>().isLoading,
                        builder: (context, value, child) => LoadingIndicator(
                          active: value,
                        ),
                      )
                    )
                  ),
                ],
              ),
              // place sheet on extra stack above map so touch events won't pass through
              QuestionDialog(
                question: _selectedQuestion
              )
            ],
          )
        ),
      )
    );
  }


  void _onStopAreaTap(StopArea stopArea, BuildContext context) async {
    context.read<OSMElementProvider>().loadStopAreaElements(stopArea);

    // move camera to stop area and include default sheet size as bottom padding
    final radius = context.read<StopAreasProvider>().stopAreaDiameter / 2;

    _mapController.animateToBounds(
      ticker: this,
      bounds: stopArea.bounds.enlargeByMeters(radius),
    );
  }


  void _onOsmElementTap(OSMElement osmElement) async {
    final questions = await _questionCatalog;
    _selectedQuestion.value = questions[Random().nextInt(questions.length)];

    // move camera to stop area and include default sheet size as bottom padding
    final mediaQuery = MediaQuery.of(context);
    final paddingBottom =
      (mediaQuery.size.height - mediaQuery.padding.top - mediaQuery.padding.bottom) * 0.4;

    // TODO: take padding into account
    // TODO: handle ways and relations

    if (osmElement is OSMNode) {
      // move camera to element and include default sheet size as bottom padding
      _mapController.animateTo(
        ticker: this,
        location: LatLng(osmElement.lat, osmElement.lon),
        zoom: 17
      );
    }
  }


  Future<List<Question>> parseQuestions() async {
    final questionJsonData = await rootBundle.loadString("assets/questions/question_catalog.json");
    final questionJson = jsonDecode(questionJsonData).cast<Map<String, dynamic>>();
    return questionJson.map<Question>((question) => Question.fromJSON(question)).toList();
  }


  @override
  void dispose() {
    _cameraTracker.dispose();
    super.dispose();
  }
}