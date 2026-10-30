import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import '/api/osm_authentication_api.dart';
import '/commons/app_config.dart';
import '/commons/osm_config.dart';
import '/commons/panoramax_config.dart';
import '/models/element_photo.dart';

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

  /// Exchanges only the OSM identity proof; never submit the OSM access token.
  Future<String> exchangeIdentity(String idToken) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/osm/exchange',
      data: {'id_token': idToken},
      options: Options(followRedirects: false),
    );
    final token = response.data?['jwt_token'];
    if (token is! String || token.isEmpty) {
      throw const PanoramaxUploadException(authenticationFailed: true);
    }
    return token;
  }

  Options _auth(String token) => Options(headers: {'Authorization': 'Bearer $token'});

  Future<({String token, String name})> authenticateForUpload({required int osmUserId}) async {
    const storage = FlutterSecureStorage();
    final osm = OSMAuthenticationAPI();
    final owner = '$kOSMServer:$osmUserId';
    final existing = await storage.read(key: tokenKey);
    final storedOwner = await storage.read(key: kPanoramaxAccountKey);
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
    await storage.write(key: kPanoramaxAccountKey, value: owner);
    return (token: token, name: user.name);
  }

  ElementPhoto forAccount(ElementPhoto photo, String accountId) {
    if (photo.upload.accountId == accountId) return photo;
    final changed = photo.upload.accountId != null;
    return ElementPhoto(
      id: changed ? const Uuid().v4() : photo.id,
      osmType: photo.osmType,
      osmId: photo.osmId,
      label: photo.label,
      path: photo.path,
      upload: PhotoUploadState(
        accountId: accountId,
        setId: changed ? null : photo.upload.setId,
        fileUploaded: !changed && photo.upload.fileUploaded,
        completed: !changed && photo.upload.completed,
      ),
    );
  }

  Future<void> upload(ElementPhoto photo, String token) async {
    if (photo.upload.completed) return;
    final options = _auth(token);
    if (photo.upload.setId == null) {
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
            'semantics': MultipartFile.fromString(
              jsonEncode([
                {'key': 'osm_id', 'value': photo.osmReference},
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
