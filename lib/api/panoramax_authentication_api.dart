import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '/commons/app_config.dart';
import '/commons/osm_config.dart';
import '/commons/panoramax_config.dart';
import 'osm_authentication_api.dart';
import 'panoramax_api.dart';

/// Exchanges an OSM identity proof for the instance's own upload credential.
class PanoramaxAuthenticationAPI {
  static const _storage = FlutterSecureStorage();

  Future<String?> restore({required int osmUserId}) async {
    final token = await _storage.read(key: kPanoramaxTokenKey);
    final owner = await _storage.read(key: kPanoramaxAccountKey);
    if (token == null || owner != '$kOSMServer:$osmUserId') return null;
    final api = PanoramaxAPI();
    try {
      await api.account(token);
      return token;
    } on DioException catch (error) {
      if (![401, 403].contains(error.response?.statusCode)) rethrow;
      await logout();
      return null;
    } finally {
      api.dispose();
    }
  }

  Future<String> authenticate(OSMIdentityToken idToken) async {
    if (idToken.isExpired) throw const PanoramaxUploadException(authenticationFailed: true);
    final client = Dio(
      BaseOptions(
        baseUrl: '$kPanoramaxUrl/api',
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'User-Agent': kAppUserAgent},
      ),
    );
    try {
      final response = await client.post<Map<String, dynamic>>(
        '/auth/osm/exchange',
        data: {'id_token': idToken.encoded},
        options: Options(followRedirects: false),
      );
      final token = response.data?['jwt_token'];
      if (token is! String || token.isEmpty) {
        throw const PanoramaxUploadException(authenticationFailed: true);
      }
      await client.get<dynamic>(
        '/users/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      await _storage.write(key: kPanoramaxTokenKey, value: token);
      await _storage.write(key: kPanoramaxAccountKey, value: '$kOSMServer:${idToken.subject}');
      return token;
    } finally {
      client.close();
    }
  }

  Future<void> logout() => Future.wait([
    _storage.delete(key: kPanoramaxTokenKey),
    _storage.delete(key: kPanoramaxAccountKey),
  ]);
}
