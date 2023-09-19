import 'package:flutter/material.dart' hide ProxyElement;
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_stop/api/osm_element_upload_api.dart';
import 'package:open_stop/models/authenticated_user.dart';
import 'package:open_stop/models/element_conditions/sub_condition_matcher.dart';
import 'package:open_stop/models/element_processing/element_processor.dart';
import 'package:open_stop/models/element_variants/base_element.dart';
import 'package:open_stop/models/element_conditions/element_condition.dart';
import 'package:open_stop/models/map_features/map_feature_definition.dart';
import 'package:open_stop/models/map_features/map_features.dart';
import 'package:open_stop/models/osm_element_type.dart' as app;
import 'package:open_stop/models/stop_area_processing/stop.dart';
import 'package:open_stop/models/stop_area_processing/stop_area.dart';
import 'package:osm_api/osm_api.dart';

void main() async {
  final auth = BasicAuth(
    username: 'testuser',
    password: 'testpass'
  );

  const endPoint = 'http://127.0.0.1:3000/api/0.6';
  const changesetCreatedBy = 'test created by';
  const changesetLocale = 'test locale';
  const changesetSource = 'test source';

  final simpleStopArea = StopArea(const [
    Stop(
      location: LatLng(10.00001, 20.00001),
      name: 'Stop1'
    )
  ], const LatLng(10.00001, 20.00001), 200);

  final doubleStopArea = StopArea(const [
    Stop(
      location: LatLng(10.00001, 20.00001),
      name: 'Stop1'
    ),
    Stop(
      location: LatLng(10.00002, 20.00002),
      name: 'Stop2'
    )
  ], const LatLng(10.00001, 20.00001), 200);

  final tripleStopArea = StopArea(const [
    Stop(
      location: LatLng(10.00001, 20.00001),
      name: 'Stop1'
    ),
    Stop(
      location: LatLng(10.00002, 20.00002),
      name: 'Stop2'
    ),
    Stop(
      location: LatLng(10.00003, 20.00003),
      name: 'Stop2'
    )
  ], const LatLng(10.00001, 20.00001), 200);

  const tags01 = {'map_feature_1': 'map_feature_1_value'};
  const tags02 = {'map_feature_2': 'map_feature_2_value'};
  const tags03 = {'map_feature_3': 'map_feature_3_value'};
  const tags04 = {'map_feature_4': 'map_feature_4_value'};

  MapFeatures.mockDefinitions([
    MapFeatureDefinition(
      label: (locale, tags) {
        return 'MapFeature1';
      },
      icon: Icons.close,
      conditions: [
        ElementCondition([
          TagsSubCondition.fromJson(tags01),
          const ElementTypeSubCondition([app.OSMElementType.node, app.OSMElementType.openWay]),
        ]),
      ],
    ),
    MapFeatureDefinition(
      label: (locale, tags) {
        return 'MapFeature2';
      },
      icon: Icons.close,
      conditions: [
        ElementCondition([
          TagsSubCondition.fromJson(tags02),
          const ElementTypeSubCondition([app.OSMElementType.node]),
        ]),
      ],
    ),
    MapFeatureDefinition(
      label: (locale, tags) {
        return 'MapFeature3';
      },
      icon: Icons.close,
      conditions: [
        ElementCondition([
          TagsSubCondition.fromJson(tags03),
          const ElementTypeSubCondition([app.OSMElementType.openWay]),
        ]),
      ],
    ),
    MapFeatureDefinition(
      label: (locale, tags) {
        return 'MapFeature4 with very long name that exceeds the 255 OSM character length. Looooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooong';
      },
      icon: Icons.close,
      conditions: [
        ElementCondition([
          TagsSubCondition.fromJson(tags04),
          const ElementTypeSubCondition([app.OSMElementType.openWay]),
        ]),
      ],
    ),
  ]);

  late final OSMAPI osmapi;
  final elementProcessor = OSMElementProcessor();
  late final List<OSMNode> baseNodes;
  late final List<OSMWay> baseWays;
  late final List<OSMRelation> baseRelations;
  late final AuthenticatedUser user;


  setUpAll(() async {
    osmapi = OSMAPI(
      baseUrl: 'http://127.0.0.1:3000/api/0.6',
      authentication: auth
    );

    final changesetId = await osmapi.createChangeset({
      'comment': 'Add dummy platforms'
    });

    // create some elements

    baseNodes = await Future.wait([
      osmapi.createElement(
        OSMNode(10, 20, tags: Map.of(tags01)),
        changesetId
      ),
      osmapi.createElement(
        OSMNode(10.00001, 20.00001, tags: Map.of(tags02)),
        changesetId
      ),
      osmapi.createElement(
        OSMNode(10.00001, 20.00002),
        changesetId
      ),
      osmapi.createElement(
        OSMNode(10.00002, 20.00001),
        changesetId
      )
    ]);

    baseWays = await Future.wait([
      osmapi.createElement(
        OSMWay([baseNodes[2].id, baseNodes[3].id], tags: Map.of(tags03)),
        changesetId
      ),
    ]);

    baseRelations = await Future.wait([
      osmapi.createElement(
        OSMRelation(
          [OSMMember(type: OSMElementType.way, ref: baseWays[0].id)],
          tags: Map.of(tags04),
        ),
        changesetId
      ),
    ]);

    elementProcessor.add(OSMElementBundle(
      nodes: baseNodes,
      ways: baseWays,
      relations: baseRelations,
    ));

    await osmapi.closeChangeset(changesetId);

    final userDetails = await osmapi.getCurrentUserDetails();
    user = AuthenticatedUser(
      authentication: auth,
      name: userDetails.name,
      id: userDetails.id,
      preferredLanguages: userDetails.preferredLanguages
    );
  });


  tearDown(() async {
    // close all open changesets
    final openChangesets = await osmapi.queryChangesets(
      open: true,
      uid: user.id,
    );
    await Future.wait(
      openChangesets.map((changeset) => osmapi.closeChangeset(changeset.id))
    );
  });


  test('Test osm element upload changeset generation/updating', () async {
    final uploadApi01 = OSMElementUploadAPI(
      stopArea: simpleStopArea,
      authenticatedUser: user,
      endPoint: endPoint,
      changesetCreatedBy: changesetCreatedBy,
      changesetLocale: changesetLocale,
      changesetSource: changesetSource,
    );

    // update first node for simple stop area

    await ProxyElement(
      elementProcessor.find(OSMElementType.node, baseNodes[0].id)!, additionalTags: {
      'bench': 'yes',
      'height': '100',
    }).publish(uploadApi01);

    // check if one changeset of the currently open changesets contains the expected tags.
    final changesetTagList01 = (await osmapi.queryChangesets(
      open: true,
      uid: user.id,
    )).map((c) => c.tags);
    expect(changesetTagList01, anyElement(equals({
      'created_by': uploadApi01.changesetCreatedBy,
      'locale': uploadApi01.changesetLocale,
      'source': uploadApi01.changesetSource,
      'comment': 'Details zu MapFeature1 im Haltestellenbereich Stop1 hinzugefügt.'
    })));

    // update second node for simple stop area

    await ProxyElement(
      elementProcessor.find(OSMElementType.node, baseNodes[1].id)!, additionalTags: {
      'bench': 'no',
      'height': '10',
    }).publish(uploadApi01);

    // check if one changeset of the currently open changesets contains the expected tags.
    final changesetTagList02 = (await osmapi.queryChangesets(
      open: true,
      uid: user.id,
    )).map((c) => c.tags);
    expect(changesetTagList02, anyElement(equals({
      'created_by': uploadApi01.changesetCreatedBy,
      'locale': uploadApi01.changesetLocale,
      'source': uploadApi01.changesetSource,
      'comment': 'Details zu MapFeature2 und MapFeature1 im Haltestellenbereich Stop1 hinzugefügt.',
    })));

    // update first node again for simple stop area

    await ProxyElement(
      elementProcessor.find(OSMElementType.node, baseNodes[0].id)!, additionalTags: {
      'width': '20',
    }).publish(uploadApi01);

    // check if one changeset of the currently open changesets contains the expected tags.
    final changesetTagList03 = (await osmapi.queryChangesets(
      open: true,
      uid: user.id,
    )).map((c) => c.tags);
    expect(changesetTagList03, anyElement(equals({
      'created_by': uploadApi01.changesetCreatedBy,
      'locale': uploadApi01.changesetLocale,
      'source': uploadApi01.changesetSource,
      'comment': 'Details zu MapFeature1 und MapFeature2 im Haltestellenbereich Stop1 hinzugefügt.',
    })));

    // update way for double stop area

    final uploadApi02 = OSMElementUploadAPI(
      stopArea: doubleStopArea,
      authenticatedUser: user,
      endPoint: endPoint,
      changesetCreatedBy: changesetCreatedBy,
      changesetLocale: changesetLocale,
      changesetSource: changesetSource,
    );

    await ProxyElement(
      elementProcessor.find(OSMElementType.way, baseWays[0].id)!, additionalTags: {
      'width': '20',
    }).publish(uploadApi02);

    // check if one changeset of the currently open changesets contains the expected tags.
    final changesetTagList04 = (await osmapi.queryChangesets(
      open: true,
      uid: user.id,
    )).map((c) => c.tags);
    expect(changesetTagList04, anyElement(equals({
      'created_by': uploadApi02.changesetCreatedBy,
      'locale': uploadApi02.changesetLocale,
      'source': uploadApi02.changesetSource,
      'comment': 'Details zu MapFeature3, MapFeature1 und MapFeature2 im Haltestellenbereich Stop1 hinzugefügt.',
    })));

    // update way for triple stop area

    final uploadApi03 = OSMElementUploadAPI(
      stopArea: tripleStopArea,
      authenticatedUser: user,
      endPoint: endPoint,
      changesetCreatedBy: changesetCreatedBy,
      changesetLocale: changesetLocale,
      changesetSource: changesetSource,
    );

    await ProxyElement(
      elementProcessor.find(OSMElementType.way, baseWays[0].id)!, additionalTags: {
      'width': '10',
    }).publish(uploadApi03);

    // check if one changeset of the currently open changesets contains the expected tags.
    final changesetTagList05 = (await osmapi.queryChangesets(
      open: true,
      uid: user.id,
    )).map((c) => c.tags);
    expect(changesetTagList05, anyElement(equals({
      'created_by': uploadApi03.changesetCreatedBy,
      'locale': uploadApi03.changesetLocale,
      'source': uploadApi03.changesetSource,
      'comment': 'Details zu MapFeature3, MapFeature1 und MapFeature2 im Haltestellenbereich Stop2 hinzugefügt.',
    })));

    // check if no additional changeset was created by comparing the amount of changesets each query returned
    expect(changesetTagList01.length, equals(changesetTagList02.length));
    expect(changesetTagList01.length, equals(changesetTagList03.length));
    expect(changesetTagList01.length, equals(changesetTagList04.length));
    expect(changesetTagList01.length, equals(changesetTagList05.length));

    // check if upload of the elements was successful by downloading the nodes from the server and checking them
    final serverNodes = await osmapi.getNodes(baseNodes.map((node) => node.id));
    expect(serverNodes, equals(baseNodes));
    final serverWays = await osmapi.getWays(baseWays.map((way) => way.id));
    expect(serverWays, equals(baseWays));
  });


  test('Test osm element upload with changeset comment exceeding max length', () async {
    final stopAreaWithLongName = StopArea(const [
      Stop(
        location: LatLng(10.00001, 20.00001),
        name: 'Stop area with name longer than 255 characters - loooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooong'
      ),
    ], const LatLng(10.00001, 20.00001), 200);

    // update changeset with map feature and stop area of long name

    final uploadApi = OSMElementUploadAPI(
      stopArea: stopAreaWithLongName,
      authenticatedUser: user,
      endPoint: endPoint,
      changesetCreatedBy: changesetCreatedBy,
      changesetLocale: changesetLocale,
      changesetSource: changesetSource,
    );

    await ProxyElement(
      elementProcessor.find(OSMElementType.relation, baseRelations[0].id)!, additionalTags: {
      'foo': 'bar',
    }).publish(uploadApi);

    // check if one changeset of the currently open changesets contains the expected tags.
    final changesetTagList = (await osmapi.queryChangesets(
      open: true,
      uid: user.id,
    )).map((c) => c.tags);

    expect(changesetTagList.any((e) => e['comment']?.length == 255), isTrue);
    expect(changesetTagList, anyElement(equals({
      'created_by': uploadApi.changesetCreatedBy,
      'locale': uploadApi.changesetLocale,
      'source': uploadApi.changesetSource,
      'comment': 'Details zu Element im Haltestellenbereich Stop area with name longer than 255 characters - looooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo',
    })));

    // check if upload of the relation was successful by downloading the relation from the server and comparing it
    final serverRelations = await osmapi.getRelations(baseRelations.map((rel) => rel.id));
    expect(serverRelations, equals(baseRelations));
  });
}
