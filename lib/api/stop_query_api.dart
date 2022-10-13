import 'dart:math';

import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import '/models/stop.dart';


/// This class exposes API calls for querying [Stop]s via the Overpass API.

class StopQueryAPI {

  static const _query =
    '[out:json][timeout:1000][bbox];'
    'nwr["public_transport"="platform"];'
    'out tags center;';

  final int maxRetries;

  final Duration retryDelay;

  final Duration sendTimeout;

  final Duration receiveTimeout;

  final List<String> apiServers;

  final _dio = Dio();

  final _random = Random();

  StopQueryAPI({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.sendTimeout = const Duration(seconds: 10),
    this.receiveTimeout = const Duration(seconds: 15),
    this.apiServers = const [
      'https://overpass.kumi.systems/api/interpreter',
      'https://overpass-api.de/api/interpreter',
    ],
  });


  /// Method to query all stops from a specific bbox via Overpass API.
  /// This method will throw [Dio] connection errors.

  Future<Iterable<Stop>> queryByBBox(LatLng southWest, LatLng northEast) {
    return _queryByBBox(southWest, northEast);
  }


  /// Actual query method that calls itself recursively by incrementing its retry counter till [maxRetries] is reached.

  Future<Iterable<Stop>> _queryByBBox(LatLng southWest, LatLng northEast, [ int retryCount = 1 ]) async {
    // get random url from server list
    final url = apiServers[_random.nextInt(apiServers.length)];

    try {
      final response = await _dio.get<Map<String, dynamic>>(url,
        queryParameters: {
          'data': _query,
          'bbox': '${southWest.longitude},${southWest.latitude},${northEast.longitude},${northEast.latitude}'
        },
        options: Options(
          sendTimeout: sendTimeout.inMilliseconds,
          receiveTimeout: receiveTimeout.inMilliseconds,
        ),
      );
      return _queryResponseToStops(response);
    }
    catch(error) {
      if (retryCount < maxRetries) {
        return Future.delayed(
          retryDelay,
          () => _queryByBBox(southWest, northEast, retryCount + 1)
        );
      }
      rethrow;
    }
  }


  /// Method to convert the Overpass API response to a lazy [Iterable] of [Stop]s.

  Iterable<Stop> _queryResponseToStops(Response<Map<String, dynamic>> response) sync* {
    if (response.data?['elements'] != null) {
      for (final element in response.data!['elements']) {
        yield Stop.fromOverpassJSON(element);
      }
    }
  }


  /// A method to terminate the api client and cleanup any open connections.
  /// This should be called inside the widgets dispose callback.

  void dispose() {
    _dio.close(force: true);
  }
}
