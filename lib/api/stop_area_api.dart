import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:dio/dio.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:h3_flutter/h3_flutter.dart';

import '../models/stop_area/stop_area.dart';

class StopAreaAPI {
  final Dio _dio;

  StopAreaAPI({
    String endPoint = 'https://openstop.pages.dev',
  }) : _dio = Dio(
         BaseOptions(
           baseUrl: endPoint,
         ),
       );

  Stream<StopArea> queryByH3Id(BigInt id) {
    return _getStopAreas('$id.csv');
  }

  Stream<StopArea> _getStopAreas(String tileName) async* {
    final response = await _dio.get<ResponseBody>(
      tileName,
      options: Options(
        responseType: ResponseType.stream,
      ),
    );
    if (response.data != null) {
      yield* response.data!.stream
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(csv.decoder)
          // skip table header
          .skip(1)
          .map((row) => row.cast<String>())
          .map(StopArea.fromCSV);
    } else {
      throw Exception('Response body is empty');
    }
  }

  void dispose() {
    _dio.close(force: true);
  }
}

extension H3CellIdentifier on LatLngBounds {
  /// Calculates the H3 hexagon ids occupying this bounding box.
  List<BigInt> toH3Ids({
    required int resolution,
  }) {
    final h3 = const H3Factory().load();
    return h3.polyfill(
      resolution: resolution,
      coordinates: [
        GeoCoord(lat: south, lon: west),
        GeoCoord(lat: north, lon: west),
        GeoCoord(lat: north, lon: east),
        GeoCoord(lat: south, lon: east),
        // Close loop required??????????????????????????
      ],
    );
  }
}
