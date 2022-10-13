import 'package:osm_api/osm_api.dart';

import '/models/authenticated_user.dart';
import '/commons/app_config.dart' as app_config;
import '/commons/osm_config.dart' as osm_config;
import '/models/map_feature_collection.dart';
import '/models/stop_area.dart';


// NOTE:
// A potential problem for finding related changeset is that the generated
// changeset bbox can be larger then the stop area bbox,
// because the stop area bbox doesn't take the dimensions of ways into account.


class OSMElementUploadAPI {
  final MapFeatureCollection mapFeatureCollection;

  AuthenticatedUser _authenticatedUser;

  String changesetCreatedBy;

  String changesetSource;

  String changesetLocale;

  final OSMAPI _osmApi;

  OSMElementUploadAPI({
    required this.mapFeatureCollection,
    required AuthenticatedUser authenticatedUser,
    String endPoint = '${osm_config.osmServerUri}/api/0.6',
    this.changesetCreatedBy = '${app_config.appName} ${app_config.appVersion}',
    this.changesetSource = 'survey',
    this.changesetLocale = 'de'
  }) :
    _authenticatedUser = authenticatedUser,
    _osmApi = OSMAPI(
      authentication: authenticatedUser.authentication,
      baseUrl: endPoint,
      connectTimeout: 10000,
      receiveTimeout: 15000,
    );


  set authenticatedUser(AuthenticatedUser value) {
    _authenticatedUser = value;
    _osmApi.authentication = _authenticatedUser.authentication;
  }

  AuthenticatedUser get authenticatedUser => _authenticatedUser;


  Future<T> updateOsmElement<T extends OSMElement>(StopArea stopArea, T updatedElement) async {
    final changesetData = {
      'created_by': changesetCreatedBy,
      'source': changesetSource,
      'locale': changesetLocale
    };
    var changesetId = await _getReusableChangesetId(stopArea);

    // update existing changeset tags
    if (changesetId != null) {
      // gather all previously modified elements of this changeset
      final changes = await _osmApi.getChangesetChanges(changesetId);
      changesetData['comment'] = _changesetCommentBuilder(
        stopArea, [updatedElement, ...changes.modify.elements]
      );
      await _osmApi.updateChangeset(changesetId, changesetData);
    }
    // create new changeset
    else {
      changesetData['comment'] = _changesetCommentBuilder(
        stopArea, [updatedElement]
      );
      changesetId = await _osmApi.createChangeset(changesetData);
    }

    return await _osmApi.updateElement(updatedElement, changesetId);
  }


  /// Get any open changeset that was created by our app and is inside the current stop area.

  Future<int?> _getReusableChangesetId(StopArea stopArea) async {
    final bbox = stopArea.bounds;
    // get existing open changesets that was created by the user
    final changesets = await _osmApi.queryChangesets(
      open: true,
      uid: _authenticatedUser.id,
      bbox: BoundingBox(bbox.west, bbox.south, bbox.east, bbox.north)
    );

    try {
      return changesets.firstWhere((changeset) {
        return changeset.tags['created_by'] == changesetCreatedBy;
      }).id;
    }
    on StateError {
      return null;
    }
  }


  /// Build the changeset comment based on the surrounding stop area and changed osm elements.

  String _changesetCommentBuilder(StopArea stopArea, Iterable<OSMElement> osmElements) {
    const mainString = 'Details zu %s1 im Haltestellenbereich%s2 hinzugefügt.';
    String mapFeatureNames, stopNames;

    // use set to automatically remove duplicates
    final mapFeatureSet = Set<String>.from(
      osmElements
      .map((osmElement) => mapFeatureCollection.getMatchingFeature(osmElement)?.name)
      // filter null for elements that do not have a matching MapFeature
      .whereType<String>()
    );
    mapFeatureNames = _stringConcatenationBuilder(mapFeatureSet);
    // fallback name string
    if (mapFeatureNames.isEmpty) mapFeatureNames = 'Karten-Objekt';

    // use set to automatically remove duplicates
    final stopNameSet = Set<String>.from(
      stopArea.stops
      .where((stop) => stop.name.isNotEmpty)
      .map((stop) => stop.name)
    );
    stopNames = _stringConcatenationBuilder(stopNameSet);
    // add leading space
    if (stopNames.isNotEmpty) stopNames = ' $stopNames';

    return mainString.replaceFirst('%s1', mapFeatureNames).replaceFirst('%s2', stopNames);
  }


  /// Concatenate a list of strings based on a separator and conjunction string.

  String _stringConcatenationBuilder(
    Iterable<String> stringList, {
    String separatorString = ', ',
    String conjunctionString = ' und '
  }) {
    if (stringList.length > 1) {
      // concatenate all elements except the last element
      return stringList.take(stringList.length - 1).join(separatorString)
      // add last element with conjunction string
      + conjunctionString + stringList.last;
    }
    return stringList.join(separatorString);
  }


  /// A method to terminate the api client and cleanup any open connections.
  /// This should be called inside the widgets dispose callback.

  dispose() {
    _osmApi.dispose();
  }
}
