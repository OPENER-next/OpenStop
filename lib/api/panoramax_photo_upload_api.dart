import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:osm_api/osm_api.dart';

import '/commons/app_config.dart';
import '/commons/panoramax_config.dart';
import '/models/element_variants/element_identifier.dart';
import '/models/panoramax_photo.dart';

class PanoramaxPhotoUploadAPI {
  final Dio _client;

  PanoramaxPhotoUploadAPI({
    required OAuth2 authentication,
    String endPoint = '$kPanoramaxUrl/api',
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

  Future<void> upload({
    required List<PanoramaxPhoto> photos,
    required ElementIdentifier target,
    required String label,
  }) async {
    if (photos.isEmpty) return;
    try {
      final semantics = [
        {'key': 'osm_id', 'value': target.osmReference},
      ];
      final response = await _client.post<Map<String, dynamic>>(
        '/upload_sets',
        data: {
          'title': 'OpenStop: $label (${target.osmReference})',
          'estimated_nb_files': photos.length,
          'no_split': true,
          'no_deduplication': true,
          'visibility': 'anyone',
          'semantics': semantics,
        },
      );
      final path = '/upload_sets/${response.data!['id']}';
      for (final photo in photos) {
        try {
          final response = await _client.post<Map<String, dynamic>>(
            '$path/files',
            data: FormData.fromMap({
              'file': await MultipartFile.fromFile(photo.path, filename: '${photo.id}.jpg'),
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
        } on DioException catch (error) {
          if (error.response?.statusCode != 409) rethrow;
          // A retry can find its preassigned UUID in a previous upload set.
          final data = error.response?.data;
          final duplicates = data is Map ? data['upload_sets'] : null;
          final existing = duplicates is List
              ? duplicates
                    .whereType<Map>()
                    .where((item) => item['existing_item_id'] == photo.id)
                    .firstOrNull
              : null;
          if (existing == null) {
            if ((duplicates is List && duplicates.isNotEmpty) ||
                (data is Map && data['existing_item'] is Map)) {
              throw const PanoramaxPhotoUploadException(isDuplicate: true);
            }
            rethrow;
          }
          await _client.post<dynamic>('/upload_sets/${existing['upload_set_id']}/complete');
        }
      }
      await _client.post<dynamic>('$path/complete');
    } on DioException {
      throw const PanoramaxPhotoUploadException();
    }
  }

  void dispose() => _client.close();
}

/// Upload failures forwarded without Dio's multipart file streams.
class PanoramaxPhotoUploadException implements Exception {
  final bool isDuplicate;

  const PanoramaxPhotoUploadException({this.isDuplicate = false});
}
