import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_map/flutter_map.dart';

import '/commons/app_config.dart';

/// This class exposes API calls for making Overpass API requests.

class OverpassQueryAPI {
  final int maxRetries;

  final Duration retryDelay;

  final List<String> apiServers;

  final Dio _dio;

  final _random = Random();

  OverpassQueryAPI({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
    Duration sendTimeout = const Duration(seconds: 20),
    Duration receiveTimeout = const Duration(seconds: 30),
    String userAgent = kAppUserAgent,
    this.apiServers = const [
      'https://overpass.kumi.systems/api/interpreter',
      'https://overpass-api.de/api/interpreter',
    ],
  }) : _dio = Dio(
         BaseOptions(
           sendTimeout: sendTimeout,
           receiveTimeout: receiveTimeout,
           headers: {
             'User-Agent': userAgent,
           },
         ),
       );

  /// Method to execute an Overpass query.
  ///
  /// If [bbox] is given the query will be limited to the given bbox.
  /// See https://wiki.openstreetmap.org/wiki/Overpass_API/Overpass_QL#Global_bounding_box_(bbox)
  ///
  /// The query timeout can be set via the [timeout] parameter.
  ///
  /// This method will throw [Dio] connection errors.

  Future<T> query<T>(
    OverpassQuery<T> query, {
    LatLngBounds? bbox,
    Duration timeout = const Duration(seconds: 1),
  }) async {
    return query.responseTransformer(
      await _query({
        'data': query._fullQuery(
          timeout: timeout,
          globalBBox: bbox,
        ),
      }),
    );
  }

  /// Actual query method that calls itself recursively by incrementing its retry counter till [maxRetries] is reached.

  Future<Map<String, dynamic>?> _query(
    Map<String, dynamic> queryParameters, [
    int retryCount = 1,
  ]) async {
    // get random url from server list
    final url = apiServers[_random.nextInt(apiServers.length)];

    try {
      return (await _dio.get<Map<String, dynamic>>(
        url,
        queryParameters: queryParameters,
      )).data;
    } catch (error) {
      if (retryCount < maxRetries) {
        return Future.delayed(
          retryDelay,
          () => _query(queryParameters, retryCount + 1),
        );
      }
      rethrow;
    }
  }

  /// A method to terminate the api client and cleanup any open connections.
  /// This should be called inside the widgets dispose callback.

  void dispose() {
    _dio.close(force: true);
  }
}

/// Base class for Overpass queries.

abstract class OverpassQuery<T> {
  String _fullQuery({required Duration timeout, LatLngBounds? globalBBox}) {
    return (_queryHead(
      timeout: timeout,
      globalBBox: globalBBox,
    )..write(query)).toString();
  }

  StringBuffer _queryHead({required Duration timeout, LatLngBounds? globalBBox}) {
    final buffer = StringBuffer('[out:json]');

    buffer
      ..write('[timeout:')
      ..write(timeout.inMilliseconds)
      ..write(']');

    if (globalBBox != null) {
      buffer
        ..write('[bbox:')
        ..write(globalBBox.south)
        ..write(',')
        ..write(globalBBox.west)
        ..write(',')
        ..write(globalBBox.north)
        ..write(',')
        ..write(globalBBox.east)
        ..write(']');
    }
    return buffer..write(';');
  }

  /// The Overpass query body without header properties such as `[json]`.

  String get query;

  /// Callback to map the JSON response to an actual class or format it otherwise.

  T responseTransformer(Map<String, dynamic>? response);
}
