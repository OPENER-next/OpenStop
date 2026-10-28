import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '/api/osm_authentication_api.dart';
import '/commons/app_config.dart';
import '/commons/osm_config.dart';
import '/models/stop_photo.dart';

const kPanoramaxUrl = 'https://osm-lens.vee.network';

class PanoramaxAPI {
  static const tokenKey = 'panoramaxToken';
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

  /// Exchanges only the OSM identity proof; never submit the OSM access token.
  Future<String> exchangeIdentity(String idToken) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/osm/exchange',
      data: {'id_token': idToken},
      options: Options(followRedirects: false),
    );
    final token = response.data?['jwt_token'];
    if (token is! String || token.isEmpty) {
      throw const FormatException('Panoramax did not return an upload credential');
    }
    return token;
  }

  Options _auth(String token) => Options(headers: {'Authorization': 'Bearer $token'});

  Future<({String token, String name})> authenticateForUpload({required int osmUserId}) async {
    const storage = FlutterSecureStorage();
    final osm = OSMAuthenticationAPI();
    final owner = '$kOSMServer:$osmUserId';
    final existing = await storage.read(key: tokenKey);
    final storedOwner = await storage.read(key: 'panoramaxOsmAccount');
    if (existing != null && storedOwner == owner) {
      try {
        return (token: existing, name: (await account(existing)).name);
      } on DioException catch (error) {
        if (![401, 403].contains(error.response?.statusCode)) rethrow;
        await storage.delete(key: tokenKey);
      }
    }
    final identity = await osm.identityTokenForUpload(expectedUserId: osmUserId);
    final token = await exchangeIdentity(identity);
    final user = await account(token);
    await storage.write(key: tokenKey, value: token);
    await storage.write(key: 'panoramaxOsmAccount', value: owner);
    return (token: token, name: user.name);
  }

  Future<void> upload(StopPhoto photo, String token) async {
    if (photo.completed) return;
    final options = _auth(token);
    if (photo.uploadSetId == null) {
      final response = await _client.post<Map<String, dynamic>>(
        '/upload_sets',
        options: options,
        data: {
          'title': 'OpenStop: ${photo.label} (${photo.osmReference})',
          'estimated_nb_files': 1,
          'no_split': true,
          'no_deduplication': true,
          'visibility': 'anyone',
          'semantics': [
            {'key': 'osm_id', 'value': photo.osmReference},
          ],
        },
      );
      photo.uploadSetId = response.data!['id'] as String;
    }
    final path = '/upload_sets/${photo.uploadSetId}';
    if (!photo.fileUploaded) {
      try {
        final response = await _client.post<Map<String, dynamic>>(
          '$path/files',
          options: options,
          data: FormData.fromMap({
            'file': await MultipartFile.fromFile(photo.path, filename: '${photo.id}.jpg'),
            'picture_id': photo.id,
            'isBlurred': false,
            'semantics': MultipartFile.fromString(
              jsonEncode([
                {'key': 'osm_id', 'value': photo.osmReference},
              ]),
              contentType: DioMediaType('application', 'json'),
            ),
          }),
        );
        if (response.data?['rejected'] != null) {
          throw StateError('Panoramax rejected the photo');
        }
      } on DioException catch (error) {
        if (error.response?.statusCode != 409) rethrow;
        final response = await _client.get<Map<String, dynamic>>('$path/files', options: options);
        final files = (response.data!['files'] as List<dynamic>).cast<Map<String, dynamic>>();
        if (!files.any((file) => file['picture_id'] == photo.id && file['rejected'] == null)) {
          rethrow;
        }
      }
      photo.fileUploaded = true;
    }
    final status = await _client.get<Map<String, dynamic>>(path, options: options);
    if (status.data?['completed'] != true) {
      await _client.post<dynamic>('$path/complete', options: options);
    }
    photo.completed = true;
  }

  void dispose() => _client.close();
}

/// Upload failures forwarded from the worker without Dio's multipart file streams.
class PanoramaxUploadException implements Exception {
  final bool authenticationFailed;

  const PanoramaxUploadException({required this.authenticationFailed});
}
