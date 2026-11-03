import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '/commons/app_config.dart';
import '/commons/panoramax_config.dart';
import '/models/element_variants/element_identifier.dart';
import '/models/panoramax_photo.dart';

class PanoramaxAPI {
  static const tokenKey = kPanoramaxTokenKey;
  final Dio _client;

  PanoramaxAPI({Dio? client})
    : _client =
          client ??
          Dio(
            BaseOptions(
              baseUrl: '$kPanoramaxUrl/api',
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 60),
              sendTimeout: const Duration(minutes: 3),
              headers: {'User-Agent': kAppUserAgent},
            ),
          );

  Future<({String id, String name})> account(String token) async {
    final response = await _client.get<Map<String, dynamic>>('/users/me', options: _auth(token));
    return (id: response.data!['id'] as String, name: response.data!['name'] as String);
  }

  Options _auth(String token) => Options(headers: {'Authorization': 'Bearer $token'});

  PanoramaxPhoto forAccount(PanoramaxPhoto photo, String accountId) {
    if (photo.upload.accountId == accountId) return photo;
    final changed = photo.upload.accountId != null;
    return PanoramaxPhoto(
      id: changed ? const Uuid().v4() : photo.id,
      path: photo.path,
      captureLocation: photo.captureLocation,
      upload: PhotoUploadState(
        accountId: accountId,
        setId: changed ? null : photo.upload.setId,
        fileUploaded: !changed && photo.upload.fileUploaded,
        completed: !changed && photo.upload.completed,
      ),
    );
  }

  Future<void> upload(
    PanoramaxPhoto photo,
    String token, {
    required ElementIdentifier target,
    required String label,
  }) async {
    if (photo.upload.completed) return;
    final osmReference = '${target.type.name}/${target.id}';
    final options = _auth(token);
    if (photo.upload.setId == null) {
      final response = await _client.post<Map<String, dynamic>>(
        '/upload_sets',
        options: options,
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
      photo.upload.setId = response.data!['id'] as String;
    }
    final path = '/upload_sets/${photo.upload.setId}';
    if (!photo.upload.fileUploaded) {
      try {
        final response = await _client.post<Map<String, dynamic>>(
          '$path/files',
          options: options,
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
        final response = await _client.get<Map<String, dynamic>>('$path/files', options: options);
        final files = (response.data!['files'] as List<dynamic>).cast<Map<String, dynamic>>();
        if (!files.any((file) => file['picture_id'] == photo.id && file['rejected'] == null)) {
          throw const PanoramaxUploadException(authenticationFailed: false);
        }
      }
      photo.upload.fileUploaded = true;
    }
    final status = await _client.get<Map<String, dynamic>>(path, options: options);
    if (status.data?['completed'] != true) {
      await _client.post<dynamic>('$path/complete', options: options);
    }
    photo.upload.completed = true;
  }

  void dispose() => _client.close();
}

/// Upload failures forwarded from the worker without Dio's multipart file streams.
class PanoramaxUploadException implements Exception {
  final bool authenticationFailed;

  const PanoramaxUploadException({required this.authenticationFailed});
}
