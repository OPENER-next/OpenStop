import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:osm_api/osm_api.dart';

import '/commons/app_config.dart';
import '/commons/panoramax_config.dart';
import '/models/element_variants/base_element.dart';
import '/models/panoramax_photo.dart';

class PanoramaxAPI {
  final Dio _client;
  final _uploads = <String, Future<void>>{};
  final _uploadSets = <String, String>{};

  PanoramaxAPI({
    required OAuth2 authentication,
    String endPoint = '$kPanoramaxUrl/api',
    Dio? client,
  }) : _client =
           client ??
           Dio(
             BaseOptions(
               baseUrl: endPoint,
               connectTimeout: const Duration(seconds: 20),
               receiveTimeout: const Duration(seconds: 60),
               sendTimeout: const Duration(minutes: 3),
               headers: {'User-Agent': kAppUserAgent},
             ),
           ) {
    updateAuthentication(authentication);
  }

  void updateAuthentication(OAuth2 value) {
    _client.options.headers['Authorization'] = value.getAuthorizationHeader();
  }

  /// Reuse successful or in-flight uploads. Failed uploads can resume their set.
  Future<void> upload(
    PanoramaxPhoto photo, {
    required ProcessedElement target,
    required String label,
  }) {
    return _uploads.putIfAbsent(
      photo.id,
      () => _upload(photo, target, label).then<void>(
        (_) {},
        onError: (Object error, StackTrace stack) {
          _uploads.remove(photo.id);
          Error.throwWithStackTrace(error, stack);
        },
      ),
    );
  }

  Future<bool> _containsPhoto(String path, PanoramaxPhoto photo) async {
    final response = await _client.get<Map<String, dynamic>>('$path/files');
    final files = (response.data!['files'] as List<dynamic>).cast<Map<String, dynamic>>();
    return files.any((file) => file['picture_id'] == photo.id && file['rejected'] == null);
  }

  Future<void> _upload(PanoramaxPhoto photo, ProcessedElement target, String label) async {
    final osmReference = '${target.type.name}/${target.id}';
    var setId = _uploadSets[photo.id];
    var fileUploaded = false;
    if (setId == null) {
      final response = await _client.post<Map<String, dynamic>>(
        '/upload_sets',
        data: {
          'title': 'OpenStop: $label ($osmReference)',
          'estimated_nb_files': 1,
          'no_split': true,
          'no_deduplication': true,
          'visibility': 'anyone',
          'semantics': [
            {'key': 'osm_id', 'value': osmReference},
          ],
        },
      );
      setId = response.data!['id'] as String;
      _uploadSets[photo.id] = setId;
    } else {
      fileUploaded = await _containsPhoto('/upload_sets/$setId', photo);
    }
    final path = '/upload_sets/$setId';
    if (!fileUploaded) {
      try {
        final response = await _client.post<Map<String, dynamic>>(
          '$path/files',
          data: FormData.fromMap({
            'file': await MultipartFile.fromFile(photo.path, filename: '${photo.id}.jpg'),
            'picture_id': photo.id,
            'isBlurred': false,
            if (photo.captureLocation case final location?) ...{
              'override_latitude': location.latitude,
              'override_longitude': location.longitude,
            },
            'semantics': MultipartFile.fromString(
              jsonEncode([
                {'key': 'osm_id', 'value': osmReference},
              ]),
              contentType: DioMediaType('application', 'json'),
            ),
          }),
        );
        if (response.data?['rejected'] != null) {
          throw const PanoramaxUploadException(authenticationFailed: false);
        }
      } on DioException catch (error) {
        if (error.response?.statusCode != 409) rethrow;
        if (!await _containsPhoto(path, photo)) {
          throw const PanoramaxUploadException(authenticationFailed: false);
        }
      }
    }
    final status = await _client.get<Map<String, dynamic>>(path);
    if (status.data?['completed'] != true) {
      await _client.post<dynamic>('$path/complete');
    }
  }

  void dispose() => _client.close();
}

/// Upload failures forwarded from the worker without Dio's multipart file streams.
class PanoramaxUploadException implements Exception {
  final bool authenticationFailed;

  const PanoramaxUploadException({required this.authenticationFailed});
}
