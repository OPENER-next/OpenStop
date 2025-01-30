import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:temaki_flutter/temaki_flutter.dart';

import '/models/element_conditions/element_condition.dart';
import '/models/element_conditions/sub_condition_matcher.dart';
import '/models/element_conditions/tag_value_matcher.dart';
import '/models/element_variants/base_element.dart';
import '/models/osm_element_type.dart';
import 'map_feature_definition.dart';
import 'map_feature_representation.dart';

/// Singleton class that acts as a pre-defined [List] of [MapFeatureDefinition].
///
/// To get a pre-defined [MapFeatureDefinition] either use
/// `MapFeatures().representElement(element);` or `MapFeatures()[index];`

class MapFeatures extends ListBase<MapFeatureDefinition> {
  static MapFeatures _instance = MapFeatures._internal();

  factory MapFeatures() => _instance;

  /// Overrides the pre-defined map features with custom ones.
  ///
  /// This is only intended for testing purposes.

  factory MapFeatures.mockDefinitions(Iterable<MapFeatureDefinition> mapFeatures) {
    return _instance = MapFeatures._internal(mapFeatures);
  }

  final UnmodifiableListView<MapFeatureDefinition> _definitions;

  MapFeatures._internal([Iterable<MapFeatureDefinition>? defs])
    // sort map feature definitions by priority in descending order to improve matching performance in representElement
    : _definitions = UnmodifiableListView((defs ?? _globalDefinitions).sorted(
      (featureA, featureB) => featureB.priority - featureA.priority,
    ));


  /// Compare the defined Map Features with the given OSM element and return
  /// the best matching [MapFeatureRepresentation].
  ///
  /// If no matching [MapFeatureDefinition] can be found a dummy [MapFeatureRepresentation] is returned.

  MapFeatureRepresentation representElement(ProcessedElement osmElement) {
    // since the features are already pre-sorted by priority we can simply return the first match
    try {
      final matchingMapFeature = _definitions.firstWhere(
        (mapFeature) =>  mapFeature.matchesBy(osmElement) != null,
      );
      return matchingMapFeature.resolve(osmElement);
    }
    on StateError {
      // construct dummy MapFeatureRepresentation
      return MapFeatureRepresentation.fromElement(element: osmElement);
    }
  }

  @override
  int get length => _definitions.length;

  @override
  set length(int newLength) {
     throw UnsupportedError('Cannot change the length of an unmodifiable list');
  }

  @override
  MapFeatureDefinition operator [](int index) {
    return _definitions[index];
  }

  @override
  void operator []=(int index, MapFeatureDefinition value) {
    throw UnsupportedError('Cannot modify an unmodifiable list');
  }
}


//////////////////////////////////////
/// Hardcoded list of map features ///
//////////////////////////////////////

/// Defines all map features with their names, icons and conditions.
// TODO: make whole list const one day when https://github.com/dart-lang/language/issues/1048 is implemented
final _globalDefinitions = <MapFeatureDefinition>[
  MapFeatureDefinition(
    priority: 1,
    label: (locale, tags) {
      final name = tags['name'];
      final localRef = tags['local_ref'];

      if (name != null) {
        return localRef != null ? '$name\n${locale.mapFeatureBusPlatformNumber(localRef)}' : name;
      }
      else if (localRef != null) {
        return locale.mapFeatureBusPlatformNumber(localRef);
      }
      else {
        return locale.mapFeatureBusStop;
      }
    },
    icon: MdiIcons.bus,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'public_transport': StringValueMatcher('platform'),
          'bus': StringValueMatcher('yes'),
        }),
      ]),
      ElementCondition([
        TagsSubCondition({
          'public_transport': StringValueMatcher('platform'),
          'highway': StringValueMatcher('bus_stop'),
        }),
      ]),
      ElementCondition([
        TagsSubCondition({
          'highway': StringValueMatcher('platform'),
        })
      ]),
    ],
  ),
  MapFeatureDefinition(
    priority: 1,
    label: (locale, tags) {
      final name = tags['name'];
      final localRef = tags['local_ref'] ?? tags['ref'];

      if (name != null) {
        return localRef != null ? '$name\n${locale.mapFeatureTrainPlatformNumber(localRef)}' : name;
      }
      else if (localRef != null) {
        return locale.mapFeatureTrainPlatformNumber(localRef);
      }
      else {
        return locale.mapFeatureTrainPlatform;
      }
    },
    icon: MdiIcons.train,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'public_transport': StringValueMatcher('platform'),
          'train': StringValueMatcher('yes'),
        })
      ]),
    ],
  ),
  MapFeatureDefinition(
    priority: 1,
    label: (locale, tags) {
      final name = tags['name'];
      final localRef = tags['local_ref'];

      if (name != null) {
        return localRef != null ? '$name\n${locale.mapFeatureBusPlatformNumber(localRef)}' : name;
      }
      else if (localRef != null) {
        return locale.mapFeatureBusPlatformNumber(localRef);
      }
      else {
        return locale.mapFeatureTramStop;
      }
    },
    icon: MdiIcons.tram,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'public_transport': StringValueMatcher('platform'),
          'railway': StringValueMatcher('platform'),
        }),
      ]),
      ElementCondition([
        TagsSubCondition({
          'public_transport': StringValueMatcher('platform'),
          'tram': StringValueMatcher('yes'),
        }),
      ]),
    ],
  ),
  MapFeatureDefinition(
    label: (locale, tags) {
      final name = tags['name'];
      return name ?? locale.mapFeaturePlatform;
    },
    icon: MdiIcons.busStopCovered,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'public_transport': StringValueMatcher('platform'),
        }),
        ElementTypeSubCondition([OSMElementType.openWay, OSMElementType.closedWay, OSMElementType.relation])
      ]),
    ],
  ),
  MapFeatureDefinition(
    label: (locale, tags) {
      final name = tags['name'];
      return name ?? locale.mapFeatureStopPole;
    },
    icon: MdiIcons.busStop,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'public_transport': StringValueMatcher('platform'),
        }),
        ElementTypeSubCondition([OSMElementType.node])
      ]),
    ],
  ),
  MapFeatureDefinition(
    label: (locale, tags) {
      final name = tags['name'];
      return name ?? locale.mapFeatureStation;
    },
    icon: MdiIcons.home,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'public_transport': StringValueMatcher('station'),
          'railway': StringValueMatcher('station'),
        })
      ]),
      ElementCondition([
        TagsSubCondition({
          'public_transport': StringValueMatcher('station'),
          'amenity': StringValueMatcher('bus_station'),
        })
      ]),
    ],
  ),
  MapFeatureDefinition(
    label: (locale, tags) {
      final operatorName = tags['operator:short'] ?? tags['operator'];
      return operatorName != null
        ? '$operatorName ${locale.mapFeatureTicketSalesPoint}'
        : locale.mapFeatureTicketSalesPoint;
    },
    icon: TemakiIcons.ticket,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'shop': StringValueMatcher('ticket'),
          'tickets:public_transport': StringValueMatcher('yes'),
        }),
        ElementTypeSubCondition([OSMElementType.node])
      ]),
    ],
  ),
  MapFeatureDefinition(
    label: (locale, _) => locale.mapFeatureInformationPoint,
    icon: MdiIcons.informationVariant,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'tourism': StringValueMatcher('information'),
          'information': StringValueMatcher('office'),
        }),
        ElementTypeSubCondition([OSMElementType.node])
      ]),
    ],
  ),
  MapFeatureDefinition(
    priority: 1,
    label: (locale, _) => locale.mapFeatureStationMap,
    icon: TemakiIcons.infoBoard,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'tourism': StringValueMatcher('information'),
          'information': StringValueMatcher('map'),
          'map_type': StringValueMatcher('public_transport'),
          'map_size': StringValueMatcher('site'),
        }),
        ElementTypeSubCondition([OSMElementType.node])
      ]),
    ],
  ),
  MapFeatureDefinition(
    label: (locale, tags) {
      final operatorName = tags['operator:short'] ?? tags['operator'];
      return operatorName != null
        ? '$operatorName ${locale.mapFeatureTicketMachine}'
        : locale.mapFeatureTicketMachine;
    },
    icon: TemakiIcons.vendingTickets,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'amenity': StringValueMatcher('vending_machine'),
          'vending': StringValueMatcher('public_transport_tickets'),
        }),
        ElementTypeSubCondition([OSMElementType.node])
      ]),
    ],
  ),
  MapFeatureDefinition(
    label: (locale, _) => locale.mapFeatureParkingSpot,
    icon: MdiIcons.parking,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'amenity': StringValueMatcher('parking'),
        }),
        ElementTypeSubCondition([OSMElementType.node, OSMElementType.closedWay])
      ]),
      ElementCondition([
        TagsSubCondition({
          'amenity': StringValueMatcher('parking'),
          'type': StringValueMatcher('multipolygon'),
        }),
        ElementTypeSubCondition([OSMElementType.relation])
      ]),
    ],
  ),
  MapFeatureDefinition(
    label: (locale, _) => locale.mapFeatureTaxiStand,
    icon: MdiIcons.taxi,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'amenity': StringValueMatcher('taxi'),
        }),
        ElementTypeSubCondition([OSMElementType.node])
      ]),
    ],
  ),
  MapFeatureDefinition(
    label: (locale, _) => locale.mapFeatureToilets,
    icon: MdiIcons.humanMaleFemale,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'amenity': StringValueMatcher('toilets'),
        }),
        ElementTypeSubCondition([OSMElementType.node])
      ]),
    ],
  ),
  MapFeatureDefinition(
    label: (locale, _) => locale.mapFeatureLuggageLockers,
    icon: TemakiIcons.vendingLockers,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'amenity': StringValueMatcher('luggage_locker'),
        }),
        ElementTypeSubCondition([OSMElementType.node])
      ]),
    ],
  ),
  MapFeatureDefinition(
    label: (locale, _) => locale.mapFeatureLuggageTransport,
    icon: MdiIcons.dolly,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'amenity': StringValueMatcher('trolley_bay'),
        }),
        ElementTypeSubCondition([OSMElementType.node])
      ]),
    ],
  ),
  MapFeatureDefinition(
    label: (locale, _) => locale.mapFeatureInformationTerminal,
    icon: MdiIcons.informationVariant,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'tourism': StringValueMatcher('information'),
          'information': StringValueMatcher('terminal'),
        }),
        ElementTypeSubCondition([OSMElementType.node])
      ]),
    ],
  ),
  MapFeatureDefinition(
    label: (locale, _) => locale.mapFeatureInformationCallPoint,
    icon: MdiIcons.phoneMessage,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'tourism': StringValueMatcher('information'),
          'information': StringValueMatcher('phone'),
        }),
        ElementTypeSubCondition([OSMElementType.node])
      ]),
    ],
  ),
  MapFeatureDefinition(
    priority: 1,
    label: (locale, _) => locale.mapFeatureHelpPoint,
    icon: MdiIcons.phoneInTalk,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'emergency': StringValueMatcher('phone'),
          'tourism': StringValueMatcher('information'),
          'information': StringValueMatcher('phone'),
        }),
        ElementTypeSubCondition([OSMElementType.node])
      ]),
    ],
  ),
  MapFeatureDefinition(
    label: (locale, _) => locale.mapFeatureEmergencyCallPoint,
    icon: MdiIcons.phoneAlert,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'emergency': StringValueMatcher('phone'),
        }),
        ElementTypeSubCondition([OSMElementType.node])
      ]),
    ],
  ),
  MapFeatureDefinition(
    label: (locale, _) => locale.mapFeatureEntrance,
    icon: MdiIcons.door,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'entrance': NotEmptyValueMatcher(),
        }),
        ElementTypeSubCondition([OSMElementType.node])
      ]),
      ElementCondition([
        TagsSubCondition({
          'door': MultiValueMatcher([
            StringValueMatcher('yes'),
            StringValueMatcher('hinged'),
            StringValueMatcher('revolving'),
            StringValueMatcher('sliding'),
            StringValueMatcher('folding'),
          ]),
        }),
        ElementTypeSubCondition([OSMElementType.node])
      ]),
      ElementCondition([
        TagsSubCondition({
          'railway': MultiValueMatcher([
            StringValueMatcher('subway_entrance'),
            StringValueMatcher('train_station_entrance'),
          ]),
        }),
        ElementTypeSubCondition([OSMElementType.node])
      ]),
    ],
  ),
  MapFeatureDefinition(
    label: (locale, tags) => tags['name'] ?? locale.mapFeatureFootpath,
    icon: TemakiIcons.pedestrian,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'highway': StringValueMatcher('footway'),
          'bicycle': MultiValueMatcher([
            StringValueMatcher('no'),
            EmptyValueMatcher(),
          ]),
        }),
        ElementTypeSubCondition([OSMElementType.openWay, OSMElementType.closedWay])
      ]),
      ElementCondition([
        TagsSubCondition({
          'highway': StringValueMatcher('path'),
          'foot': MultiValueMatcher([
            StringValueMatcher('yes'),
            StringValueMatcher('designated'),
          ]),
          'bicycle': MultiValueMatcher([
            StringValueMatcher('no'),
            EmptyValueMatcher(),
          ]),
        }),
        ElementTypeSubCondition([OSMElementType.openWay, OSMElementType.closedWay])
      ]),
    ],
  ),
  MapFeatureDefinition(
    label: (locale, tags) => tags['name'] ?? locale.mapFeatureCyclePath,
    icon: MdiIcons.bike,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'highway': StringValueMatcher('cycleway'),
          'foot': MultiValueMatcher([
            StringValueMatcher('no'),
            EmptyValueMatcher(),
          ]),
        }),
        ElementTypeSubCondition([OSMElementType.openWay, OSMElementType.closedWay])
      ]),
      ElementCondition([
        TagsSubCondition({
          'highway': StringValueMatcher('path'),
          'bicycle': MultiValueMatcher([
            StringValueMatcher('yes'),
            StringValueMatcher('designated'),
          ]),
          'foot': MultiValueMatcher([
            StringValueMatcher('no'),
            EmptyValueMatcher(),
          ]),
        }),
        ElementTypeSubCondition([OSMElementType.openWay, OSMElementType.closedWay])
      ]),
    ],
  ),
  MapFeatureDefinition(
    label: (locale, tags) => tags['name'] ?? locale.mapFeatureFootAndCyclePath,
    icon: TemakiIcons.pedestrianAndCyclist,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'highway': StringValueMatcher('footway'),
          'bicycle': MultiValueMatcher([
            StringValueMatcher('yes'),
            StringValueMatcher('designated'),
          ]),
        }),
        ElementTypeSubCondition([OSMElementType.openWay, OSMElementType.closedWay])
      ]),
      ElementCondition([
        TagsSubCondition({
          'highway': StringValueMatcher('cycleway'),
          'foot': MultiValueMatcher([
            StringValueMatcher('yes'),
            StringValueMatcher('designated'),
          ]),
        }),
        ElementTypeSubCondition([OSMElementType.openWay, OSMElementType.closedWay])
      ]),
      ElementCondition([
        TagsSubCondition({
          'highway': StringValueMatcher('path'),
          'bicycle': MultiValueMatcher([
            StringValueMatcher('yes'),
            StringValueMatcher('designated'),
          ]),
          'foot': MultiValueMatcher([
            StringValueMatcher('yes'),
            StringValueMatcher('designated'),
          ]),
        }),
        ElementTypeSubCondition([OSMElementType.openWay, OSMElementType.closedWay])
      ]),
      ElementCondition([
        TagsSubCondition({
          'highway': StringValueMatcher('path'),
          'bicycle': EmptyValueMatcher(),
          'foot': EmptyValueMatcher(),
        }),
        ElementTypeSubCondition([OSMElementType.openWay, OSMElementType.closedWay])
      ]),
    ],
  ),
  MapFeatureDefinition(
    label: (locale, _) => locale.mapFeatureStairs,
    icon: MdiIcons.stairs,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'highway': StringValueMatcher('steps'),
        }),
        ElementTypeSubCondition([OSMElementType.openWay])
      ]),
    ],
  ),
  MapFeatureDefinition(
    label: (locale, _) => locale.mapFeatureElevator,
    icon: MdiIcons.elevatorPassenger,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'highway': StringValueMatcher('elevator'),
        }),
        ElementTypeSubCondition([OSMElementType.node, OSMElementType.closedWay])
      ]),
    ],
  ),
  MapFeatureDefinition(
    priority: 1,
    label: (locale, _) => locale.mapFeatureEscalator,
    icon: MdiIcons.escalator,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'highway': StringValueMatcher('steps'),
          'conveying': MultiValueMatcher([
            StringValueMatcher('yes'),
            StringValueMatcher('forward'),
            StringValueMatcher('backward'),
            StringValueMatcher('reversible'),
          ]),
        }),
        ElementTypeSubCondition([OSMElementType.openWay])
      ]),
    ],
  ),
  MapFeatureDefinition(
    label: (locale, _) => locale.mapFeatureCycleBarrier,
    icon: TemakiIcons.cycleBarrier,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'barrier': StringValueMatcher('cycle_barrier'),
        }),
        ElementTypeSubCondition([OSMElementType.node])
      ]),
    ],
  ),
  MapFeatureDefinition(
    label: (locale, _) => locale.mapFeatureCrossing,
    icon: TemakiIcons.pedCyclistCrosswalk,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'highway': StringValueMatcher('crossing'),
        }),
        ElementTypeSubCondition([OSMElementType.node])
      ]),
    ],
  ),
  MapFeatureDefinition(
    label: (locale, _) => locale.mapFeatureTramCrossing,
    icon: TemakiIcons.crossingTramSolid,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'railway': StringValueMatcher('tram_crossing'),
        }),
        ElementTypeSubCondition([OSMElementType.node])
      ]),
    ],
  ),
  MapFeatureDefinition(
    label: (locale, _) => locale.mapFeatureRailroadCrossing,
    icon: TemakiIcons.crossingRailSolid,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'railway': StringValueMatcher('crossing'),
        }),
        ElementTypeSubCondition([OSMElementType.node])
      ]),
    ],
  ),
  MapFeatureDefinition(
    priority: 1,
    label: (locale, _) => locale.mapFeatureFootwayCrossing,
    icon: TemakiIcons.pedestrianCrosswalk,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'highway': StringValueMatcher('footway'),
          'footway': StringValueMatcher('crossing'),
          'bicycle': MultiValueMatcher([
            EmptyValueMatcher(),
            StringValueMatcher('no'),
          ]),
        }),
      ]),
      ElementCondition([
        TagsSubCondition({
          'highway': StringValueMatcher('path'),
          'path': StringValueMatcher('crossing'),
          'foot': MultiValueMatcher([
            StringValueMatcher('yes'),
            StringValueMatcher('designated'),
          ]),
          'bicycle': MultiValueMatcher([
            EmptyValueMatcher(),
            StringValueMatcher('no'),
          ]),
        }),
      ]),
    ],
  ),
  MapFeatureDefinition(
    priority: 1,
    label: (locale, _) => locale.mapFeatureCyclewayCrossing,
    icon: TemakiIcons.cyclistCrosswalk,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'highway': StringValueMatcher('cycleway'),
          'cycleway': StringValueMatcher('crossing'),
          'foot': MultiValueMatcher([
            EmptyValueMatcher(),
            StringValueMatcher('no'),
          ]),
        }),
      ]),
      ElementCondition([
        TagsSubCondition({
          'highway': StringValueMatcher('path'),
          'path': StringValueMatcher('crossing'),
          'bicycle': MultiValueMatcher([
            StringValueMatcher('yes'),
            StringValueMatcher('designated'),
          ]),
          'foot': MultiValueMatcher([
            EmptyValueMatcher(),
            StringValueMatcher('no'),
          ]),
        }),
        ElementTypeSubCondition([OSMElementType.openWay])
      ]),
    ],
  ),
  MapFeatureDefinition(
    priority: 1,
    label: (locale, _) => locale.mapFeatureCrossing,
    icon: TemakiIcons.pedCyclistCrosswalk,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'highway': StringValueMatcher('cycleway'),
          'cycleway': StringValueMatcher('crossing'),
          'foot': MultiValueMatcher([
            StringValueMatcher('yes'),
            StringValueMatcher('designated'),
          ]),
        }),
        ElementTypeSubCondition([OSMElementType.openWay])
      ]),
      ElementCondition([
        TagsSubCondition({
          'highway': StringValueMatcher('footway'),
          'footway': StringValueMatcher('crossing'),
          'bicycle': MultiValueMatcher([
            StringValueMatcher('yes'),
            StringValueMatcher('designated'),
          ]),
        }),
        ElementTypeSubCondition([OSMElementType.openWay])
      ]),
      ElementCondition([
        TagsSubCondition({
          'highway': StringValueMatcher('path'),
          'path': StringValueMatcher('crossing'),
          'bicycle': MultiValueMatcher([
            StringValueMatcher('yes'),
            StringValueMatcher('designated'),
          ]),
          'foot': MultiValueMatcher([
            StringValueMatcher('yes'),
            StringValueMatcher('designated'),
          ]),
        }),
        ElementTypeSubCondition([OSMElementType.openWay])
      ]),
    ],
  ),
  MapFeatureDefinition(
    label: (locale, _) => locale.mapFeatureCurb,
    icon: TemakiIcons.kerbRaised,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'barrier': StringValueMatcher('kerb'),
        }),
        ElementTypeSubCondition([OSMElementType.node])
      ]),
    ],
  ),
  MapFeatureDefinition(
    priority: 1,
    label: (locale, _) => locale.mapFeaturePedestrianLights,
    icon: TemakiIcons.trafficSignals,
    conditions: const [
      ElementCondition([
        TagsSubCondition({
          'highway': StringValueMatcher('crossing'),
          'crossing': StringValueMatcher('traffic_signals'),
        }),
        ElementTypeSubCondition([OSMElementType.node, OSMElementType.openWay])
      ]),
      ElementCondition([
        TagsSubCondition({
          'highway': StringValueMatcher('crossing'),
          'crossing:signals': StringValueMatcher('yes'),
        }),
        ElementTypeSubCondition([OSMElementType.node, OSMElementType.openWay])
      ]),
    ],
  ),
];
