import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:animated_location_indicator/animated_location_indicator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '/widgets/geometry_layer.dart';
import '/view_models/user_location_provider.dart';
import '/view_models/questionnaire_provider.dart';
import '/view_models/osm_authenticated_user_provider.dart';
import '/view_models/osm_elements_provider.dart';
import '/view_models/preferences_provider.dart';
import '/view_models/stop_areas_provider.dart';
import '/utils/stream_utils.dart';
import '/commons/app_config.dart';
import '/commons/tile_layers.dart';
import '/utils/map_utils.dart';
import '/widgets/stop_area_layer/stop_area_layer.dart';
import '/widgets/osm_element_layer/osm_element_layer.dart';
import '/widgets/question_dialog/question_dialog.dart';
import '/widgets/map_overlay/map_overlay.dart';
import '/widgets/home_sidebar.dart';
import '/models/question_catalog.dart';
import '/models/stop_area.dart';
import '/models/map_feature_collection.dart';
import '/models/geometric_osm_element.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final _questionCatalog = _parseQuestionCatalog();
  late final _mapFeatureCollection = _parseOSMObjects();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        _questionCatalog,
        _mapFeatureCollection,
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // TODO: Style this properly
          return const Center(
            child: CircularProgressIndicator()
          );
        }
        else {
          final QuestionCatalog questionCatalog = snapshot.requireData[0];
          final MapFeatureCollection mapFeatureCollection = snapshot.requireData[1];

          return MultiProvider(
            providers: [
              ProxyProvider<PreferencesProvider, QuestionCatalog>(
                create: (_) => questionCatalog,
                update: (_, preferences, questionCatalog) {
                  // only update if is professional setting differs from current question catalog
                  if (!preferences.isProfessional != questionCatalog!.excludeProfessional) {
                    return questionCatalog.copyWith(
                      excludeProfessional: !preferences.isProfessional
                    );
                  }
                  return questionCatalog;
                },
              ),
              Provider.value(value: mapFeatureCollection),
              ChangeNotifierProxyProvider2<QuestionCatalog, MapFeatureCollection, OSMElementProvider>(
                create: (context) => OSMElementProvider(
                  questionCatalog: context.read<QuestionCatalog>(),
                  mapFeatureCollection: context.read<MapFeatureCollection>()
                ),
                update: (_, questionCatalog, mapFeatureCollection, osmElementProvider) {
                  return osmElementProvider!..update(
                    questionCatalog: questionCatalog,
                    mapFeatureCollection: mapFeatureCollection
                  );
                }
              ),
              ChangeNotifierProvider(
                create: (_) => UserLocationProvider()
              ),
              ChangeNotifierProvider(
                create: (_) => StopAreasProvider(
                  stopAreaRadius: 50
                )
              ),
              ChangeNotifierProvider(
                create: (_) => QuestionnaireProvider()
              ),
              ChangeNotifierProvider(
                create: (_) => OSMAuthenticatedUserProvider(),
                // do this so the previous session is loaded on start in parallel
                lazy: false,
              ),
              Provider<MapController>(
                create: (_) => MapController(),
                dispose: (_, mapController) => mapController.dispose(),
              ),
            ],
            child: const _HomeScreenContent()
          );
        }
      }
    );
  }

  Future<QuestionCatalog> _parseQuestionCatalog() async {
    final jsonData = await rootBundle.loadStructuredData<List<Map<String, dynamic>>>(
      'assets/datasets/question_catalog.json',
      (String jsonString) async => json.decode(jsonString).cast<Map<String, dynamic>>()
    );
    return QuestionCatalog.fromJson(jsonData);
  }

  Future<MapFeatureCollection> _parseOSMObjects() async {
    final jsonData = await rootBundle.loadStructuredData<List<Map<String, dynamic>>>(
      'assets/datasets/map_feature_collection.json',
      (String jsonString) async => json.decode(jsonString).cast<Map<String, dynamic>>()
    );
    return MapFeatureCollection.fromJson(jsonData);
  }
}


// Holds all UI widgets and logic of the home screen.
// The main purpose of this widget separation is to get the context with all view models.

class _HomeScreenContent extends StatefulWidget {
  static const questionDialogMaxHeightFactor = 2/3;

  const _HomeScreenContent({Key? key}) : super(key: key);

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> with TickerProviderStateMixin {
  StreamSubscription<MapEvent>? _debouncedMapStreamSubscription;
  StreamSubscription<MapEvent>? _mapStreamSubscription;

  @override
  void initState() {
    super.initState();
    // wait till context is available
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final mapController = context.read<MapController>();
      final userLocationProvider = context.read<UserLocationProvider>();
      // wait till map controller is ready
      await mapController.onReady;

      void handleInitialLocationTrackingChange() {
        if (userLocationProvider.state != LocationTrackingState.pending) {
          // if location tracking is enabled
          // jump to user position and enable camera tracking
          if (userLocationProvider.state == LocationTrackingState.enabled) {
            final position = userLocationProvider.position!;
            mapController.move(
              LatLng(position.latitude, position.longitude),
              mapController.zoom,
              id: 'CameraTracker'
            );
            userLocationProvider.shouldFollowLocation = true;
          }
          userLocationProvider.removeListener(handleInitialLocationTrackingChange);
          // load stop areas of current viewport location
          final stopAreasProvider = context.read<StopAreasProvider>();
          stopAreasProvider.loadStopAreas(mapController.bounds!);
          // add on position change handler after initial location code is finished
          userLocationProvider.addListener(_onPositionChange);
        }
      }
      userLocationProvider.addListener(handleInitialLocationTrackingChange);
      // request user position tracking
      userLocationProvider.startLocationTracking();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final mapController = context.read<MapController>();

    _debouncedMapStreamSubscription?.cancel();
    _debouncedMapStreamSubscription = mapController.mapEventStream
      .transform( DebounceTransformer(const Duration(seconds: 1)) )
      .listen(_onDebouncedMapEvent);

    _mapStreamSubscription?.cancel();
    _mapStreamSubscription = mapController.mapEventStream.listen(_onMapEvent);
  }


  @override
  Widget build(BuildContext context) {
    final tileLayerId = context.select<PreferencesProvider, TileLayerId>((pref) => pref.tileLayerId);
    final tileLayerDescription = tileLayers[tileLayerId]!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: const HomeSidebar(),
      body: Stack(
        children: [
          FlutterMap(
            mapController: context.watch<MapController>(),
            options: MapOptions(
              onTap: _onMapTap,
              enableMultiFingerGestureRace: true,
              // intentionally use read() here because changes to these properties
              // do not need to trigger rebuilds
              center: context.read<PreferencesProvider>().mapLocation,
              zoom: context.read<PreferencesProvider>().mapZoom,
              rotation: context.read<PreferencesProvider>().mapRotation,
              minZoom: tileLayerDescription.minZoom.toDouble(),
              maxZoom: tileLayerDescription.maxZoom.toDouble()
            ),
            nonRotatedChildren: [
              RepaintBoundary(
                child: FutureBuilder(
                  future: context.watch<MapController>().onReady,
                  builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                    final mapIsLoaded = snapshot.connectionState == ConnectionState.done;
                    // only show overlay when question history has no active entry
                    return !mapIsLoaded
                    ? const ModalBarrier(
                      dismissible: false,
                    )
                    : Consumer<QuestionnaireProvider>(
                      builder: (context, questionnaire,child) {
                        final noActiveEntry = !questionnaire.hasQuestions;

                        return AnimatedSwitcher(
                          switchInCurve: Curves.ease,
                          switchOutCurve: Curves.ease,
                          duration: const Duration(milliseconds: 300),
                          child: noActiveEntry
                            ? const MapOverlay()
                            : null
                        );
                      }
                    );
                  }
                )
              )
            ],
            children: [
              TileLayerWidget(
                options: TileLayerOptions(
                  overrideTilesWhenUrlChanges: true,
                  tileProvider: NetworkTileProvider(
                    headers: const {
                      'User-Agent': appUserAgent
                    }
                  ),
                  backgroundColor: Colors.transparent,
                  urlTemplate: isDarkMode && tileLayerDescription.darkVariantTemplateUrl != null
                    ? tileLayerDescription.darkVariantTemplateUrl
                    : tileLayerDescription.templateUrl,
                  minZoom: tileLayerDescription.minZoom.toDouble(),
                  maxZoom: tileLayerDescription.maxZoom.toDouble()
                ),
              ),
              Consumer2<StopAreasProvider, OSMElementProvider>(
                builder: (context, stopAreaProvider, osmElementProvider, child) {
                  return StopAreaLayer(
                    stopAreas: stopAreaProvider.stopAreas,
                    loadingStopAreas: osmElementProvider.loadingStopAreas,
                    onStopAreaTap: _onStopAreaTap,
                  );
                }
              ),
              Consumer2<QuestionnaireProvider, OSMElementProvider>(
                builder: (context, questionnaireProvider, osmElementProvider, child) {
                  final selectedElement = questionnaireProvider.workingElement;
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: (selectedElement != null)
                      ? GeometryLayer(
                        geometry: osmElementProvider.extractedOsmElements.firstWhere(
                          (element) => selectedElement.isOther(element.osmElement)
                        ).geometry,
                        key: ValueKey(selectedElement),
                      )
                      : null,
                  );
                }
              ),
              // rebuild location indicator when location access is granted
              Selector<UserLocationProvider, LocationTrackingState>(
                selector: (_, userLocationProvider) => userLocationProvider.state,
                builder: (context, state, child) {
                  return AnimatedLocationLayerWidget(
                    options: AnimatedLocationOptions()
                  );
                }
              ),
              Consumer<OSMElementProvider>(
                builder: (context, osmElementProvider, child) {
                  return OsmElementLayer(
                    onOsmElementTap: _onOsmElementTap,
                    geoElements: osmElementProvider.extractedOsmElements
                  );
                }
              ),
            ],
          ),
          // place sheet on extra stack above map so map pan events won't pass through
          Consumer<QuestionnaireProvider>(
            builder: (context, questionnaireProvider, child) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                reverseDuration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeInOutCubicEmphasized,
                switchOutCurve: Curves.ease,
                transitionBuilder: (child, animation) {
                  final offsetAnimation = Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(animation);
                  return SlideTransition(
                    position: offsetAnimation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    )
                  );
                },
                child: questionnaireProvider.hasQuestions
                  ? QuestionDialog(
                    activeQuestionIndex: questionnaireProvider.currentQuestionnaireIndex!,
                    questions: questionnaireProvider.questions,
                    answers: questionnaireProvider.answers,
                    showSummary: questionnaireProvider.isFinished,
                    maxHeightFactor: _HomeScreenContent.questionDialogMaxHeightFactor,
                    key: questionnaireProvider.key,
                  )
                  : null
              );
            }
          ),
        ],
      )
    );
  }


  void _onStopAreaTap(StopArea stopArea) {
    // hide questionnaire sheet
    final questionnaire = context.read<QuestionnaireProvider>();
    if (questionnaire.workingElement != null ) {
      questionnaire.close();
      // if a questionnaire was open then do not load or zoom fit the stop area
      return;
    }

    final osmElementProvider = context.read<OSMElementProvider>();
    osmElementProvider.loadElementsFromStopArea(stopArea);

    final mapController = context.read<MapController>();
    mapController.animateToBounds(
      ticker: this,
      bounds: stopArea.bounds,
    );
  }


  void _onOsmElementTap(GeometricOSMElement geometricOSMElement) async {
    final questionnaire = context.read<QuestionnaireProvider>();
    final osmElement = geometricOSMElement.osmElement;

    // show questions if a new marker is selected, else hide the current one
    if (questionnaire.workingElement == null || !questionnaire.workingElement!.isOther(osmElement)) {
      final questionCatalog = context.read<QuestionCatalog>();
      questionnaire.open(osmElement, questionCatalog);
    }
    else {
      return questionnaire.close();
    }

    final mediaQuery = MediaQuery.of(context);
    final mapController = context.read<MapController>();

    // move camera to element and include default sheet size as bottom padding
    mapController.animateToBounds(
      ticker: this,
      // use bounds method because the normal move to doesn't support padding
      // the benefit of this approach is, that it will always try to zoom in on the marker as much as possible
      bounds: geometricOSMElement.geometry.bounds,
      // calculate padding based on question dialog max height
      padding: EdgeInsets.only(
        // add hardcoded marker height for now so it is centered between the top and bottom of the marker
        top: mediaQuery.padding.top + 60,
        bottom: mediaQuery.size.height * _HomeScreenContent.questionDialogMaxHeightFactor
      ),
      // zoom in on 20 or more if the current zoom level is above 20
      // required due to clustering, because not all markers may be visible on zoom level 20
      maxZoom: max(20, mapController.zoom)
    );
  }


  void _onMapTap(position, LatLng location) {
    context.read<QuestionnaireProvider>().close();
  }


  void _onPositionChange() {
    final userLocationProvider = context.read<UserLocationProvider>();
    final position = userLocationProvider.position;
    if (position != null) {
      final stopAreasProvider = context.read<StopAreasProvider>();
      // automatically load elements from stop area if the user enters a stop area
      final enclosingStopArea = stopAreasProvider.getStopAreaByPosition(
        LatLng(position.latitude, position.longitude)
      );
      if (enclosingStopArea != null) {
        final osmElementProvider = context.read<OSMElementProvider>();
        osmElementProvider.loadElementsFromStopArea(enclosingStopArea);
      }
      // move camera to current user location
      if (userLocationProvider.isFollowingLocation) {
        final mapController = context.read<MapController>();
        mapController.animateTo(
          ticker: this,
          location: LatLng(position.latitude, position.longitude),
          duration: const Duration(milliseconds: 200),
          id: 'CameraTracker'
        );
      }
    }
  }


  void _onMapEvent(MapEvent event) {
    // cancel tracking on user interaction or any map move not caused by the camera tracker
    if (
      (event is MapEventDoubleTapZoomStart) ||
      (event is MapEventMove && event.id != 'CameraTracker' && event.targetCenter != event.center)
    ) {
      final userLocationProvider = context.read<UserLocationProvider>();
      userLocationProvider.shouldFollowLocation = false;
    }
  }


  void _onDebouncedMapEvent(MapEvent event) {
    final mapController = context.read<MapController>();

    // query stops on map interactions
    if (mapController.bounds != null && mapController.zoom > 12) {
      final stopAreasProvider = context.read<StopAreasProvider>();
      stopAreasProvider.loadStopAreas(mapController.bounds!);
    }

    // store map location on map move events
    context.read<PreferencesProvider>()
      ..mapLocation = event.center
      ..mapZoom = event.zoom
      ..mapRotation = mapController.rotation;
  }


  @override
  void dispose() {
    _debouncedMapStreamSubscription?.cancel();
    _mapStreamSubscription?.cancel();
    super.dispose();
  }
}
