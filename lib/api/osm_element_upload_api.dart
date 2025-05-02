import 'package:flutter/foundation.dart';
import 'package:osm_api/osm_api.dart';

import '/commons/osm_config.dart';
import '/models/authenticated_user.dart';
import '/models/changeset_info_generator.dart';
import '/models/element_processing/element_processor.dart';
import '/models/element_variants/base_element.dart';
import '/models/stop_area/stop_area.dart';


// NOTE:
// A potential problem for finding related changeset is that the generated
// changeset bbox can be larger then the stop area bbox,
// because the stop area bbox doesn't take the dimensions of ways into account.


class OSMElementUploadAPI {
  AuthenticatedUser _authenticatedUser;

  final OSMAPI _osmApi;

  OSMElementUploadAPI({
    required AuthenticatedUser authenticatedUser,
    String endPoint = DefaultOSMAPI.endPoint,
  }) :
    _authenticatedUser = authenticatedUser,
    _osmApi = DefaultOSMAPI(
      authentication: authenticatedUser.authentication,
      baseUrl: endPoint,
    );


  set authenticatedUser(AuthenticatedUser value) {
    _authenticatedUser = value;
    _osmApi.authentication = _authenticatedUser.authentication;
  }

  AuthenticatedUser get authenticatedUser => _authenticatedUser;


  /// Upload the given element to the OSM server.
  ///
  /// The given [ProcessedElement] must be created from the given [OSMElement]
  /// or in other words encapsulate the original element.
  ///
  /// This updates the element version on success.

  Future<OSMElement> updateOsmElement(int changesetId, OSMElement originalElement) async {
    return _osmApi.updateElement(originalElement, changesetId);
  }


  /// Creates or retrieves (and updates) a suitable changeset for the given element and returns its id.

  Future<int> createOrReuseChangeset(StopArea stopArea, ProcessedElement newElement, ChangesetInfoCallback generator) async {
    var changesetId = await getReusableChangesetId(stopArea, generator);
    // update existing changeset tags
    if (changesetId != null) {
      // gather all previously modified elements of this changeset
      final changesetElements = await getChangesetElements(changesetId);
      final changesetInfo = generator(
        stopArea, [newElement, ...changesetElements],
      );
      await _osmApi.updateChangeset(changesetId, changesetInfo.asMap());
    }
    // create new changeset
    else {
      final changesetInfo = generator(stopArea, [newElement]);
      changesetId = await _osmApi.createChangeset(changesetInfo.asMap());
    }

    return changesetId;
  }


  /// Get any open changeset that was created by our app and is inside the current stop area.

  Future<int?> getReusableChangesetId(StopArea stopArea, ChangesetInfoCallback generator) async {
    // dummy changeset info
    final changesetInfo = generator(stopArea, []);

    // get existing open changesets that was created by the user
    final changesets = await _osmApi.queryChangesets(
      open: true,
      uid: _authenticatedUser.id,
      bbox: BoundingBox(stopArea.west, stopArea.south, stopArea.east, stopArea.north)
    );

    try {
      return changesets.firstWhere((changeset) {
        return changeset.tags['created_by'] == changesetInfo.createdBy;
      }).id;
    }
    on StateError {
      return null;
    }
  }


  /// Queries all elements that were modified in the given changeset.
  ///
  /// This will also retrieve any (none modified) child elements for ways and
  /// relations which is required to create complete [ProcessedElement]s.
  /// However only the elements modified by the given changeset will be returned.

  Future<Iterable<ProcessedElement>> getChangesetElements(int changesetId) async {
    // gather all modified elements of this changeset
    final changes = await _osmApi.getChangesetChanges(changesetId);
    final changesWithChildren = await _queryFullElements(changes.modify);
    // create processed elements for all modified elements + children
    final elementProcessor = OSMElementProcessor(changesWithChildren);
    // filter processed elements to only contain the original modified elements
    // otherwise we might match elements to map features that weren't modified
    // but are children of a modified element
    return elementProcessor.elements.where((pElement) {
      return changes.modify.elements.any(
        (oElement) => pElement.isOriginal(oElement),
      );
    });
  }


  /// This will query all child elements from ways and relations in the given bundle.
  /// The returned bundle will contain all elements from the given bundle plus any child elements.

  Future<OSMElementBundle> _queryFullElements(OSMElementBundle bundle) async {
    // create new bundle with only the nodes of the original bundle
    // the ways and relations with all their children will be queried and added (if successful) to this bundle
    final newBundle = OSMElementBundle(nodes: bundle.nodes);

    // re-query ways and relations with child elements
    final requestQueue = [
      for (final way in bundle.ways) _osmApi.getFullWay(way.id),
      for (final relation in bundle.relations) _osmApi.getFullRelation(relation.id),
    ];

    // wait till all requests are resolved
    // handle them in a stream in order to catch individual errors
    await Stream.fromFutures(requestQueue)
      .handleError((Object e) {
        // catch any errors and ignore these elements
        // for example the element or its children might be deleted by now
        debugPrint('Could not query element of existing changeset: $e');
      })
      .forEach(newBundle.merge);

    return newBundle;
  }


  /// A method to terminate the api client and cleanup any open connections.
  /// This should be called inside the widgets dispose callback.

  void dispose() {
    _osmApi.dispose();
  }
}


typedef ChangesetInfoCallback = ChangesetInfo Function(
  StopArea stopArea,
  Iterable<ProcessedElement> modifiedElements,
);
