import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:animated_location_indicator/animated_location_indicator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '/view_models/incomplete_osm_elements_provider.dart';
import '/view_models/questionnaire_provider.dart';
import '/view_models/osm_authentication_provider.dart';
import '/view_models/osm_elements_provider.dart';
import '/view_models/preferences_provider.dart';
import '/view_models/stop_areas_provider.dart';
import '/helpers/camera_tracker.dart';
import '/utils/stream_debouncer.dart';
import '/commons/tile_layers.dart';
import '/utils/map_utils.dart';
import '/widgets/map_layer/stop_area_layer.dart';
import '/widgets/question_dialog/question_dialog.dart';
import '/widgets/map_overlay.dart';
import '/widgets/home_sidebar.dart';
import '/widgets/map_layer/osm_element_layer.dart';
import '/models/question_catalog.dart';
import '/models/stop_area.dart';
import '/models/map_feature_collection.dart';
import '/models/geometric_osm_element.dart';


class HomeScreen extends StatefulWidget {

  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  static const questionDialogMaxHeightFactor = 2/3;

  final MapController _mapController = MapController();

  final _stopAreasProvider = StopAreasProvider(
    stopAreaRadius: 50
  );

  late final _cameraTracker = CameraTracker(
    mapController: _mapController
  );

  late final _questionCatalog = _parseQuestionCatalog();
  late final _mapFeatureCollection = _parseOSMObjects();

  @override
  void initState() {
    super.initState();

    // query stops on map interactions
    _mapController.mapEventStream.debounce<MapEvent>(const Duration(milliseconds: 500)).listen((event) {
      if (_mapController.bounds != null && _mapController.zoom > 12) {
        _stopAreasProvider.loadStopAreas(_mapController.bounds!);
      }
    });

    _mapController.onReady.then((_) {
      // use post frame callback because initial bounds are not applied in onReady yet
      WidgetsBinding.instance?.addPostFrameCallback((duration) {
        // move to user location and start camera tracking on app start
        _cameraTracker.startTacking(initialZoom: 15);

        void handleInitialCameraStateChange() {
         if (_cameraTracker.state != CameraTrackerState.pending) {
            _cameraTracker.removeListener(handleInitialCameraStateChange);
            _stopAreasProvider.loadStopAreas(_mapController.bounds!);
          }
        }
        _cameraTracker.addListener(handleInitialCameraStateChange);
      });
    });
  }


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
                update: (_, preferences, __) {
                  return questionCatalog.filterBy(
                    difficulty: preferences.difficulty
                  );
                },
              ),
              ChangeNotifierProvider(
                create: (_) => QuestionnaireProvider()
              ),
              ChangeNotifierProvider.value(value: _cameraTracker),
              ChangeNotifierProvider.value(value: _stopAreasProvider),
              ChangeNotifierProvider(
                create: (_) => OSMAuthenticationProvider(),
                // do this so the previous session is loaded on start in parallel
                lazy: false,
              ),
              ChangeNotifierProvider(
                create: (_) => OSMElementProvider()
              ),
              ChangeNotifierProxyProvider2<OSMElementProvider, QuestionCatalog, IncompleteOSMElementProvider>(
                create: (_) => IncompleteOSMElementProvider(),
                update: (_, osmElementProvider, questionCatalog, incompleteOSMElementProvider) {
                  return incompleteOSMElementProvider!..update(osmElementProvider.loadedStopAreas, questionCatalog);
                }
              ),
              Provider.value(value: _mapController),
              Provider.value(value: mapFeatureCollection),
            ],
            builder: (context, child) {
              final tileLayerId = context.select<PreferencesProvider, TileLayerId>((pref) => pref.tileLayerId);
              final tileLayerDescription = tileLayers[tileLayerId]!;
              final isDarkMode = Theme.of(context).brightness == Brightness.dark;

              return Scaffold(
                resizeToAvoidBottomInset: false,
                drawer: const HomeSidebar(),
                body: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        onTap: (position, location) => _closeQuestionDialog(context),
                        enableMultiFingerGestureRace: true,
                        center: LatLng(50.8144951, 12.9295576),
                        zoom: 15.0,
                        minZoom: tileLayerDescription.minZoom.toDouble(),
                        maxZoom: tileLayerDescription.maxZoom.toDouble()
                      ),
                      children: [
                        TileLayerWidget(
                          options: TileLayerOptions(
                            overrideTilesWhenUrlChanges: true,
                            tileProvider: NetworkTileProvider(),
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
                              onStopAreaTap: (stopArea) => _onStopAreaTap(stopArea, context),
                            );
                          }
                        ),
                        Selector<CameraTracker, bool>(
                          selector: (_, cameraTracker) => cameraTracker.hasLocationAccess,
                          builder: (context, cameraTracker, child) {
                            return AnimatedLocationLayerWidget(
                              options: AnimatedLocationOptions()
                            );
                          }
                        ),
                        Consumer<IncompleteOSMElementProvider>(
                          builder: (context, incompleteOsmElementProvider, child) {
                            return OsmElementLayer(
                              onOsmElementTap: (osmElement) => _onOsmElementTap(osmElement, context),
                              geoElements: incompleteOsmElementProvider.loadedOsmElements
                            );
                          }
                        ),
                      ],
                      nonRotatedChildren: [
                        RepaintBoundary(
                          child: FutureBuilder(
                            future: _mapController.onReady,
                            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                              final mapIsLoaded = snapshot.connectionState == ConnectionState.done;
                              // only show overlay when question history has no active entry
                              return !mapIsLoaded
                              ? const ModalBarrier(
                                dismissible: false,
                              )
                              : Consumer<QuestionnaireProvider>(
                                builder: (context, questionnaire,child) {
                                  final noActiveEntry = !questionnaire.hasEntries;

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
                          child: questionnaireProvider.hasEntries
                            ? QuestionDialog(
                              activeQuestionIndex: questionnaireProvider.activeIndex!,
                              questionEntries: questionnaireProvider.entries!,
                              maxHeightFactor: questionDialogMaxHeightFactor,
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
          );
        }
      }
    );
  }


  void _onStopAreaTap(StopArea stopArea, BuildContext context) async {
    // hide questionnaire sheet
    final questionnaire = context.read<QuestionnaireProvider>();
    if (questionnaire.workingElement != null ) {
      questionnaire.discard();
    }

    context.read<OSMElementProvider>().loadStopAreaElements(stopArea);

    _mapController.animateToBounds(
      ticker: this,
      bounds: stopArea.bounds,
    );
  }


  void _onOsmElementTap(GeometricOSMElement geometricOSMElement, BuildContext context) async {
    final questionnaire = context.read<QuestionnaireProvider>();
    final osmElement = geometricOSMElement.osmElement;

    // show questions if a new marker is selected, else hide the current one
    if (questionnaire.workingElement == null || !questionnaire.workingElement!.isSameElement(osmElement)) {
      final questionCatalog = context.read<QuestionCatalog>();
      questionnaire.create(osmElement, questionCatalog);
    }
    else {
      return questionnaire.discard();
    }

    final mediaQuery = MediaQuery.of(context);

    // move camera to element and include default sheet size as bottom padding
    _mapController.animateToBounds(
      ticker: this,
      // use bounds method because the normal move to doesn't support padding
      // the benefit of this approach is, that it will always try to zoom in on the marker as much as possible
      bounds: LatLngBounds.fromPoints([geometricOSMElement.geometry.center]),
      // calculate padding based on question dialog max height
      padding: EdgeInsets.only(
        // add hardcoded marker height for now so it is centered between the top and bottom of the marker
        top: mediaQuery.padding.top + 60,
        bottom: mediaQuery.size.height * questionDialogMaxHeightFactor
      ),
      maxZoom: 20
    );
  }


  Future<QuestionCatalog> _parseQuestionCatalog() async {
    final jsonString = await rootBundle.loadString('assets/datasets/question_catalog.json');
    return QuestionCatalog.fromJson(jsonDecode(jsonString).cast<Map<String, dynamic>>());
  }

  Future<MapFeatureCollection> _parseOSMObjects() async {
    final jsonString = await rootBundle.loadString('assets/datasets/map_feature_collection.json');
    return MapFeatureCollection.fromJson(jsonDecode(jsonString).cast<Map<String, dynamic>>());
  }


  _closeQuestionDialog(BuildContext context) {
    context.read<QuestionnaireProvider>().discard();
  }


  @override
  void dispose() {
    _cameraTracker.dispose();
    super.dispose();
  }
}
