import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import '/utils/service_worker.dart';
import '/models/map_feature_collection.dart';

mixin MapFeatureHandler<M> on ServiceWorker<M> {

  static final _completer = Completer<MapFeatureCollection>();

  void takeMapFeatureCollectionAsset(ByteData data) {
    final jsonString = utf8.decode(data.buffer.asUint8List());
    final jsonData = json.decode(jsonString).cast<Map<String, dynamic>>();
    _completer.complete(MapFeatureCollection.fromJson(jsonData));
  }

  final mapFeatureCollection = _completer.future;
}
