import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:csv/csv.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:h3_flutter/h3_flutter.dart';

import '../commons/app_config.dart';
import '../models/stop_area/stop_area.dart';
import '../utils/file_cache.dart';

/// Allows querying stop areas from a remote server.
/// Stop areas are queried by Uber's H3 spatial index.
class StopAreaAPI {
  final Dio _dio;

  StopAreaAPI({
    String endPoint = 'https://raw.githubusercontent.com/OPENER-next/OpenStop-areas/refs/heads/result/output/',
    String userAgent = kAppUserAgent,
  }) : _dio = Dio(
         BaseOptions(
           baseUrl: endPoint,
           headers: {
             'User-Agent': userAgent,
           },
         ),
       );

  Stream<StopArea> queryByH3Id(BigInt id) {
    return _decode(_download(id));
  }

  Stream<List<int>> _download(BigInt id) async* {
    final response = await _dio.get<ResponseBody>(
      '$id.csv',
      options: Options(
        responseType: ResponseType.stream,
      ),
    );
    if (response.data != null) {
      yield* response.data!.stream;
    } else {
      throw Exception('Response body is empty');
    }
  }

  Stream<StopArea> _decode(Stream<List<int>> data) {
    return data
        .transform(utf8.decoder)
        .transform(csv.decoder)
        // skip table header
        .skip(1)
        .map((row) => row.cast<String>())
        .map(StopArea.fromCSV);
  }

  void dispose() {
    _dio.close(force: true);
  }
}

/// Disk-Cached implementation of StopAreaAPI.
class CachedStopAreaAPI extends StopAreaAPI {
  final FileCache _cache;

  CachedStopAreaAPI({
    super.endPoint,
    super.userAgent,
    Duration timeToLive = const Duration(days: 30),
    String folderName = 'stop_area_cache',
  }) : _cache = FileCache(
         timeToLive: timeToLive,
         folderName: folderName,
       );

  @override
  Stream<StopArea> queryByH3Id(BigInt id) async* {
    final idString = id.toString();
    if (await _cache.isFresh(idString)) {
      yield* _decode(_cache.read(idString).transform(gzip.decoder));
    } else {
      final splitter = StreamSplitter(_download(id));
      // write to disk
      _cache
          .write(
            idString,
            splitter.split().transform(gzip.encoder),
          )
          .catchError((Object e) => debugPrint(e.toString()))
          .ignore();
      yield* _decode(splitter.split());
      unawaited(splitter.close());
    }
  }
}

extension H3CellIdentifier on LatLngBounds {
  /// Calculates the H3 hexagon ids occupying this bounding box.
  List<BigInt> toH3Ids({
    required int resolution,
  }) {
    final h3 = const H3Factory().load();
    return h3.polygonToCellsExperimental(
      resolution: resolution,
      perimeter: [
        GeoCoord(lat: south, lon: west),
        GeoCoord(lat: south, lon: east),
        GeoCoord(lat: north, lon: east),
        GeoCoord(lat: north, lon: west),
      ],
      flag: PolygonToCellFlags.containmentOverlapping
    );
  }
}
