import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_stop/api/osm_element_upload_api.dart';
import 'package:open_stop/models/authenticated_user.dart';
import 'package:open_stop/models/map_feature.dart';
import 'package:open_stop/models/map_feature_collection.dart';
import 'package:open_stop/models/osm_condition.dart';
import 'package:open_stop/models/osm_element_type.dart' as app;
import 'package:open_stop/models/stop.dart';
import 'package:open_stop/models/stop_area.dart';
import 'package:osm_api/osm_api.dart';

void main() async {
  final auth = BasicAuth(
    username: 'testuser',
    password: 'testpass'
  );

  final simpleStopArea = StopArea([
    Stop(
      location: LatLng(10.00001, 20.00001),
      name: 'Stop1'
    )
  ], LatLng(10.00001, 20.00001), 200);

  final doubleStopArea = StopArea([
    Stop(
      location: LatLng(10.00001, 20.00001),
      name: 'Stop1'
    ),
    Stop(
      location: LatLng(10.00001, 20.00001),
      name: 'Stop2'
    )
  ], LatLng(10.00001, 20.00001), 200);

  final tripleStopArea = StopArea([
    Stop(
      location: LatLng(10.00001, 20.00001),
      name: 'Stop1'
    ),
    Stop(
      location: LatLng(10.00001, 20.00001),
      name: 'Stop2'
    ),
    Stop(
      location: LatLng(10.00001, 20.00001),
      name: 'Stop3'
    )
  ], LatLng(10.00001, 20.00001), 200);


  final mapFeatureCollection = MapFeatureCollection( const [
    MapFeature(
      name: 'MapFeature1',
      icon: Icons.close,
      conditions: [
        OsmCondition(
            {'map_feature_1': 'map_feature_1_value'},
            [app.OSMElementType.node, app.OSMElementType.openWay]
        )
      ]
    ),
    MapFeature(
      name: 'MapFeature2',
      icon: Icons.close,
      conditions: [
        OsmCondition(
          {'map_feature_2': 'map_feature_2_value'},
          [app.OSMElementType.node]
        )
      ]
    ),
    MapFeature(
      name: 'MapFeature3',
      icon: Icons.close,
      conditions: [
        OsmCondition(
          {'map_feature_3': 'map_feature_3_value'},
          [app.OSMElementType.openWay]
        )
      ]
    )
  ]);

  late OSMAPI osmapi;
  late List<OSMNode> nodes;
  late List<OSMWay> ways;
  late AuthenticatedUser user;


  setUpAll(() async {
    osmapi = OSMAPI(
      baseUrl: 'http://127.0.0.1:3000/api/0.6',
      authentication: auth
    );

    final changesetId = await osmapi.createChangeset({
      'comment': 'Add dummy platforms'
    });

    // create some elements

    nodes = await Future.wait([
      osmapi.createElement(
        OSMNode(10, 20, tags: Map.of(mapFeatureCollection[0].conditions[0].osmTags.cast<String, String>())),
        changesetId
      ),
      osmapi.createElement(
        OSMNode(10.00001, 20.00001, tags: Map.of(mapFeatureCollection[1].conditions[1].osmTags.cast<String, String>())),
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

    ways = await Future.wait([
      osmapi.createElement(
        OSMWay([nodes[2].id, nodes[3].id], tags: Map.of(mapFeatureCollection[2].conditions[2].osmTags[0])),
        changesetId
      ),
    ]);

    await osmapi.closeChangeset(changesetId);

    final userDetails = await osmapi.getCurrentUserDetails();
    user = AuthenticatedUser(
      authentication: auth,
      name: userDetails.name,
      id: userDetails.id,
      preferredLanguages: userDetails.preferredLanguages
    );
  });


  tearDownAll(() async {
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
    final uploadApi = OSMElementUploadAPI(
      mapFeatureCollection: mapFeatureCollection,
      authenticatedUser: user,
      endPoint: 'http://127.0.0.1:3000/api/0.6',
      changesetCreatedBy: 'test created by',
      changesetLocale: 'test locale',
      changesetSource: 'test source'
    );

    // update first node for simple stop area

    nodes[0].tags['bench'] = 'yes';
    nodes[0].tags['height'] = '100';
    await uploadApi.updateOsmElement(simpleStopArea, nodes[0]);
    // check if one changeset of the currently open changesets contains the expected tags.
    final changesetTagList01 = (await osmapi.queryChangesets(
      open: true,
      uid: user.id,
    )).map((c) => c.tags);
    expect(changesetTagList01, anyElement(equals({
      'created_by': uploadApi.changesetCreatedBy,
      'locale': uploadApi.changesetLocale,
      'source': uploadApi.changesetSource,
      'comment': 'Details zu MapFeature1 im Haltestellenbereich Stop1 hinzugefügt.'
    })));

    // update second node for simple stop area

    nodes[1].tags['bench'] = 'no';
    nodes[1].tags['height'] = '10';
    await uploadApi.updateOsmElement(simpleStopArea, nodes[1]);
    // check if one changeset of the currently open changesets contains the expected tags.
    final changesetTagList02 = (await osmapi.queryChangesets(
      open: true,
      uid: user.id,
    )).map((c) => c.tags);
    expect(changesetTagList02, anyElement(equals({
      'created_by': uploadApi.changesetCreatedBy,
      'locale': uploadApi.changesetLocale,
      'source': uploadApi.changesetSource,
      'comment': 'Details zu MapFeature2 und MapFeature1 im Haltestellenbereich Stop1 hinzugefügt.',
    })));

    // update first node again for simple stop area

    nodes[0].tags['width'] = '20';
    await uploadApi.updateOsmElement(simpleStopArea, nodes[0]);
    // check if one changeset of the currently open changesets contains the expected tags.
    final changesetTagList03 = (await osmapi.queryChangesets(
      open: true,
      uid: user.id,
    )).map((c) => c.tags);
    expect(changesetTagList03, anyElement(equals({
      'created_by': uploadApi.changesetCreatedBy,
      'locale': uploadApi.changesetLocale,
      'source': uploadApi.changesetSource,
      'comment': 'Details zu MapFeature1 und MapFeature2 im Haltestellenbereich Stop1 hinzugefügt.',
    })));

    // update way for double stop area

    ways[0].tags['width'] = '20';
    await uploadApi.updateOsmElement(doubleStopArea, ways[0]);
    // check if one changeset of the currently open changesets contains the expected tags.
    final changesetTagList04 = (await osmapi.queryChangesets(
      open: true,
      uid: user.id,
    )).map((c) => c.tags);
    expect(changesetTagList04, anyElement(equals({
      'created_by': uploadApi.changesetCreatedBy,
      'locale': uploadApi.changesetLocale,
      'source': uploadApi.changesetSource,
      'comment': 'Details zu MapFeature3, MapFeature1 und MapFeature2 im Haltestellenbereich Stop1 und Stop2 hinzugefügt.',
    })));

    // update way for triple stop area

    ways[0].tags['width'] = '10';
    await uploadApi.updateOsmElement(tripleStopArea, ways[0]);
    // check if one changeset of the currently open changesets contains the expected tags.
    final changesetTagList05 = (await osmapi.queryChangesets(
      open: true,
      uid: user.id,
    )).map((c) => c.tags);
    expect(changesetTagList05, anyElement(equals({
      'created_by': uploadApi.changesetCreatedBy,
      'locale': uploadApi.changesetLocale,
      'source': uploadApi.changesetSource,
      'comment': 'Details zu MapFeature3, MapFeature1 und MapFeature2 im Haltestellenbereich Stop1, Stop2 und Stop3 hinzugefügt.',
    })));


    // check if no additional changeset was created by comparing the amount of changesets each query returned
    expect(changesetTagList01.length, equals(changesetTagList02.length));
    expect(changesetTagList01.length, equals(changesetTagList03.length));
    expect(changesetTagList01.length, equals(changesetTagList04.length));
    expect(changesetTagList01.length, equals(changesetTagList05.length));

    // check if upload of the elements was successful by downloading the nodes from the server and checking them
    final serverNodes = await osmapi.getNodes(nodes.map((node) => node.id));
    expect(serverNodes, equals(nodes));
    final serverWays = await osmapi.getWays(ways.map((way) => way.id));
    expect(serverWays, equals(ways));
  });
}
