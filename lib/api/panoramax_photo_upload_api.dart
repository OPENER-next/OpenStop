import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:osm_api/osm_api.dart';

import '/api/authentication/panoramax_authentication_api.dart';
import '/commons/app_config.dart';
import '/commons/panoramax_config.dart';
import '/models/element_variants/element_identifier.dart';
import '/models/panoramax_photo.dart';

class PanoramaxPhotoUploadAPI {
  final Dio _client;

  /// How long to wait for the server to process the uploaded photos.

  final Duration processingTimeout;

  /// How often to check whether the server has processed the uploaded photos.

  final Duration processingPollInterval;

  PanoramaxPhotoUploadAPI({
    required Auth authentication,
    String endPoint = '$kPanoramaxUrl/api',
    this.processingTimeout = const Duration(minutes: 5),
    this.processingPollInterval = const Duration(seconds: 2),
  }) : _client = Dio(
         BaseOptions(
           baseUrl: endPoint,
           connectTimeout: const Duration(seconds: 20),
           receiveTimeout: const Duration(minutes: 1),
           sendTimeout: const Duration(minutes: 1),
           headers: {
             'User-Agent': kAppUserAgent,
             'Authorization': authentication.getAuthorizationHeader(),
           },
         ),
       );

  /// Uploads the photos into a new upload set and waits until the server has processed them.
  /// If anything fails the upload set is deleted again.

  Future<void> upload({
    required List<PanoramaxPhoto> photos,
    required ElementIdentifier target,
  }) async {
    if (photos.isEmpty) return;
    try {
      final semantics = [
        {'key': 'osm_id', 'value': target.osmReference},
      ];
      final uploadSetId = await _createUploadSet(
        title: 'OpenStop: ${target.osmReference}',
        fileCount: photos.length,
        semantics: semantics,
      );
      try {
        for (final photo in photos) {
          final response = await _client.post<Map<String, dynamic>>(
            '/upload_sets/$uploadSetId/files',
            data: FormData.fromMap({
              'file': await MultipartFile.fromFile(photo.file.path, filename: '${photo.id}.jpg'),
              'picture_id': photo.id,
              'isBlurred': false,
              'override_latitude': photo.captureLocation.latitude,
              'override_longitude': photo.captureLocation.longitude,
              'semantics': MultipartFile.fromString(
                jsonEncode(semantics),
                contentType: DioMediaType('application', 'json'),
              ),
            }),
          );
          final rejected = response.data?['rejected'];
          if (rejected != null) {
            throw PanoramaxPhotoUploadException(
              isDuplicate: rejected is Map && rejected['reason'] == 'file_duplicate',
            );
          }
        }
        await _completeUploadSet(uploadSetId, photos.length);
      } catch (_) {
        await _deleteUploadSet(uploadSetId);
        rethrow;
      }
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) throw const PanoramaxAuthenticationException();
      throw PanoramaxPhotoUploadException(isDuplicate: statusCode == 409);
    }
  }

  Future<String> _createUploadSet({
    required String title,
    required int fileCount,
    required List<Map<String, String>> semantics,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/upload_sets',
      data: {
        'title': title,
        'estimated_nb_files': fileCount,
        'no_split': true,
        'no_deduplication': true,
        'visibility': 'anyone',
        'semantics': semantics,
      },
    );
    return response.data!['id'] as String;
  }

  /// Completes the upload set and waits until all of its photos are processed and published.
  /// Throws if any photo is missing or could not be processed.

  Future<void> _completeUploadSet(String id, int fileCount) async {
    await _client.post<dynamic>('/upload_sets/$id/complete');

    final deadline = DateTime.now().add(processingTimeout);
    // This loop also ends when dispose() is called on the api,
    // because the closed client then throws a DioException on the next request.
    while (true) {
      final response = await _client.get<Map<String, dynamic>>('/upload_sets/$id');
      final status = response.data!['items_status'] as Map<String, dynamic>;
      if (status['broken'] != 0 || status['rejected'] != 0) {
        throw const PanoramaxPhotoUploadException();
      }
      if (response.data!['ready'] == true) {
        if (status['prepared'] != fileCount) {
          throw const PanoramaxPhotoUploadException();
        }
        return;
      }
      if (DateTime.now().isAfter(deadline)) {
        throw const PanoramaxPhotoUploadException();
      }
      await Future<void>.delayed(processingPollInterval);
    }
  }

  Future<void> _deleteUploadSet(String id) async {
    try {
      await _client.delete<dynamic>('/upload_sets/$id');
    } on DioException {
      // The original upload error is more relevant than a failed clean-up.
    }
  }

  void dispose() => _client.close();
}

/// Upload failures forwarded without Dio's multipart file streams.
class PanoramaxPhotoUploadException implements Exception {
  final bool isDuplicate;

  const PanoramaxPhotoUploadException({this.isDuplicate = false});
}
