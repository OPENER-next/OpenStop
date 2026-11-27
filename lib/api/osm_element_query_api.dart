import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:osm_api/osm_api.dart';

import '/commons/osm_config.dart';
import '/models/stop_area/stop_area.dart';
import '/utils/file_cache.dart';

/// How long downloaded elements of a stop area are kept and shown without a connection.

const kElementCacheTimeToLive = Duration(days: 7);

/// This class exposes API calls for querying [OSMElement]s via the OSM API.

class OSMElementQueryAPI {
  final OSMAPI _osmApi;

  OSMElementQueryAPI({
    // always use live osm end point for query
    // note that this breaks the upload api in development
    String endPoint = 'https://www.openstreetmap.org/api/0.6',
  }) : _osmApi = DefaultOSMAPI(
         baseUrl: endPoint,
       );

  /// Method to query all OSM elements from a specific bbox via OSM API.
  /// All direct sub elements of relations are also queried if the total member count
  /// of the relation doesn't exceed the defined [relationMemberLimit].
  /// This limit exists to prevent querying overly large relations, such as country boundaries.
  /// This method will throw [OSMAPI] connection errors.

  Future<OSMElementBundle> queryByBBox(
    LatLngBounds bbox, {
    int relationMemberLimit = 50,
  }) async {
    final bboxElementBundle = await _osmApi.getElementsByBoundingBox(
      BoundingBox(bbox.west, bbox.south, bbox.east, bbox.north),
    );
    // query all direct relation elements with less than X members
    final relations = bboxElementBundle.relations.where(
      (relation) => relation.members.length <= relationMemberLimit,
    );
    final relationsElementBundle = await _getElementsFromRelations(relations);

    return bboxElementBundle.merge(relationsElementBundle);
  }

  /// Query all elements of the supplied relations and merge them to a single [OSMElementBundle].

  Future<OSMElementBundle> _getElementsFromRelations(
    Iterable<OSMRelation> relations,
  ) {
    // query all direct relation elements (nodes, ways and relations) + nodes of ways
    final queries = relations.map(
      (relation) => _osmApi.getFullRelation(relation.id),
    );
    // merge all relation element bundles
    return Stream.fromFutures(queries).fold(
      OSMElementBundle(),
      (previous, elementBundle) => previous.merge(elementBundle),
    );
  }

  /// A method to terminate the api client and cleanup any open connections.
  /// This should be called inside the widgets dispose callback.

  void dispose() {
    _osmApi.dispose();
  }
}

/// Disk-cached element queries with one cache entry per [StopArea].
///
/// The cache only ever contains the server state of the elements.
/// Expired entries are never returned, so without a connection their stop area cannot be loaded.

class CachedOSMElementQueryAPI extends OSMElementQueryAPI {
  final FileCache _cache;

  CachedOSMElementQueryAPI({
    super.endPoint,
    Duration timeToLive = kElementCacheTimeToLive,
    String folderName = 'element_cache',
    @visibleForTesting FileCache? cache,
  }) : _cache =
           cache ??
           FileCache(
             timeToLive: timeToLive,
             folderName: folderName,
             location: FileCacheLocation.applicationSupport,
           );

  /// Returns the elements of the given stop area from the cache if the entry hasn't expired,
  /// otherwise queries them via [queryByBBox] and stores them in the cache.
  ///
  /// This method will throw [OSMAPI] connection errors.

  Future<OSMElementBundle> queryByStopArea(StopArea stopArea) async {
    // not done in the constructor, because this class is created before platform channels are available
    _cache.evictStaleOnce();
    final key = cacheKey(stopArea);
    if (await _cache.isFresh(key)) {
      try {
        final bytes = await _cache.readBytes(key);
        if (bytes != null) {
          final json = jsonDecode(utf8.decode(gzip.decode(bytes)));
          return OSMElementBundle.fromJSONObject(json as Map<String, dynamic>);
        }
      } catch (e) {
        debugPrint('Discard invalid element cache entry $key: $e');
        await _cache.delete(key);
      }
    }
    final bundle = await queryByBBox(stopArea);
    final bytes = gzip.encode(utf8.encode(jsonEncode(bundle.toJSONObject())));
    await _cache.writeBytes(key, bytes).catchError((Object e) => debugPrint(e.toString()));
    return bundle;
  }

  /// [StopArea]s have no identifier, therefore they are identified by their bounds.

  @visibleForTesting
  static String cacheKey(StopArea stopArea) {
    final bounds = [
      stopArea.south,
      stopArea.west,
      stopArea.north,
      stopArea.east,
    ].map((v) => v.toStringAsFixed(7)).join(',');
    return md5.convert(utf8.encode(bounds)).toString();
  }
}
