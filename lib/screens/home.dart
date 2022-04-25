import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:animated_location_indicator/animated_location_indicator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '/view_models/user_location_provider.dart';
import '/view_models/questionnaire_provider.dart';
import '/view_models/osm_authenticated_user_provider.dart';
import '/view_models/osm_elements_provider.dart';
import '/view_models/preferences_provider.dart';
import '/view_models/stop_areas_provider.dart';
import '/utils/network_tile_provider_with_headers.dart';
import '/utils/stream_debouncer.dart';
import '/commons/app_config.dart';
import '/commons/tile_layers.dart';
import '/utils/map_utils.dart';
import '/widgets/map_layer/stop_area_layer.dart';
import '/widgets/map_layer/osm_element_layer.dart';
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
  _HomeScreenState createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  static const questionDialogMaxHeightFactor = 2/3;

  final _mapController = MapController();

  final _stopAreasProvider = StopAreasProvider(
    stopAreaRadius: 50
  );

  final _osmElementProvider = OSMElementProvider();

  final _userLocationProvider = UserLocationProvider();

  late final _questionCatalog = _parseQuestionCatalog();
  late final _mapFeatureCollection = _parseOSMObjects();
  // required because _onPositionChange has no access to the correct context
  QuestionCatalog? _filteredQuestionCatalog;

  @override
  void initState() {
    super.initState();

    // query stops on map interactions
    _mapController.mapEventStream.debounce<MapEvent>(const Duration(milliseconds: 500)).listen((event) {
      if (_mapController.bounds != null && _mapController.zoom > 12) {
        _stopAreasProvider.loadStopAreas(_mapController.bounds!);
      }
    });

    // cancel tracking on user interaction or any map move not caused by the camera tracker
    _mapController.mapEventStream.listen((mapEvent) {
      if (
        (mapEvent is MapEventDoubleTapZoomStart) ||
        (mapEvent is MapEventMove && mapEvent.id != 'CameraTracker' && mapEvent.targetCenter != mapEvent.center)
      ) {
        _userLocationProvider.shouldFollowLocation = false;
      }
    });

    _mapController.onReady.then((_) {
      void handleInitialLocationTrackingChange() {
        if (_userLocationProvider.state != LocationTrackingState.pending) {
          // if location tracking is enabled
          // jump to user position and enable camera tracking
          if (_userLocationProvider.state == LocationTrackingState.enabled) {
            final position = _userLocationProvider.position!;
            _mapController.move(
              LatLng(position.latitude, position.longitude),
              _mapController.zoom,
              id: 'CameraTracker'
            );
            _userLocationProvider.shouldFollowLocation = true;
          }
          _userLocationProvider.removeListener(handleInitialLocationTrackingChange);
          // load stop areas of current viewport location
          _stopAreasProvider.loadStopAreas(_mapController.bounds!);
          // add on position change handler after initial location code is finished
          _userLocationProvider.addListener(_onPositionChange);
        }
      }
      _userLocationProvider.addListener(handleInitialLocationTrackingChange);
      // request user position tracking
      _userLocationProvider.startLocationTracking();
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
                  return _filteredQuestionCatalog = questionCatalog.filterBy(
                    excludeProfessional: !preferences.isProfessional
                  );
                },
                // required to update the _filteredQuestionCatalog variable
                lazy: false,
              ),
              ChangeNotifierProvider.value(value: _userLocationProvider),
              ChangeNotifierProvider.value(value: _stopAreasProvider),
              ChangeNotifierProvider.value(value: _osmElementProvider),
              ChangeNotifierProvider(
                create: (_) => QuestionnaireProvider()
              ),
              ChangeNotifierProvider(
                create: (_) => OSMAuthenticatedUserProvider(),
                // do this so the previous session is loaded on start in parallel
                lazy: false,
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
                            tileProvider: NetworkTileProviderWithHeaders(const {
                              'User-Agent': appUserAgent
                            }),
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
                              onOsmElementTap: (osmElement) => _onOsmElementTap(osmElement, context),
                              geoElements: osmElementProvider.extractedOsmElements
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


  void _onStopAreaTap(StopArea stopArea, BuildContext context) {
    // hide questionnaire sheet
    final questionnaire = context.read<QuestionnaireProvider>();
    if (questionnaire.workingElement != null ) {
      questionnaire.discard();
    }

    final questionCatalog = context.read<QuestionCatalog>();
    _osmElementProvider.loadAndExtractElements(
      stopArea, questionCatalog
    );

    _mapController.animateToBounds(
      ticker: this,
      bounds: stopArea.bounds,
    );
  }


  void _onOsmElementTap(GeometricOSMElement geometricOSMElement, BuildContext context) async {
    final questionnaire = context.read<QuestionnaireProvider>();
    final osmElement = geometricOSMElement.osmElement;

    // show questions if a new marker is selected, else hide the current one
    if (questionnaire.workingElement == null || !questionnaire.workingElement!.isProxiedElement(osmElement)) {
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


  void _onPositionChange() {
    final position = _userLocationProvider.position;
    if (position != null) {
      if (_filteredQuestionCatalog != null) {
        // automatically load elements from stop area if the user enters a stop area
        final enclosingStopArea = _stopAreasProvider.getStopAreaByPosition(
          LatLng(position.latitude, position.longitude)
        );
        if (enclosingStopArea != null) {
          _osmElementProvider.loadAndExtractElements(
            enclosingStopArea, _filteredQuestionCatalog!
          );
        }
      }
      // move camera to current user location
      if (_userLocationProvider.isFollowingLocation) {
        _mapController.animateTo(
          ticker: this,
          location: LatLng(position.latitude, position.longitude),
          duration: const Duration(milliseconds: 200),
          id: 'CameraTracker'
        );
      }
    }
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


  _closeQuestionDialog(BuildContext context) {
    context.read<QuestionnaireProvider>().discard();
  }


  @override
  void dispose() {
    super.dispose();
  }
}
