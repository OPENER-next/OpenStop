import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:osm_api/osm_api.dart';

import '/commons/app_config.dart';
import '/commons/panoramax_config.dart';
import 'panoramax_api.dart' show PanoramaxUploadException;

/// Exchanges an OSM identity proof for the instance's own upload credential.
class PanoramaxAuthenticationAPI {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'panoramaxToken';

  Dio _client() => Dio(
    BaseOptions(
      baseUrl: '$kPanoramaxUrl/api',
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 60),
      headers: {'User-Agent': kAppUserAgent},
    ),
  );

  Future<OAuth2?> restore() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) return null;
    final authentication = OAuth2(accessToken: token);
    if (await verifyAuthentication(authentication)) return authentication;
    await logout();
    return null;
  }

  /// The exchange service verifies the original JWT signature and claims.
  Future<OAuth2> authenticate(String idToken) async {
    final client = _client();
    try {
      final response = await client.post<Map<String, dynamic>>(
        '/auth/osm/exchange',
        data: {'id_token': idToken},
        options: Options(followRedirects: false),
      );
      final token = response.data?['jwt_token'];
      if (token is! String || token.isEmpty) {
        throw const PanoramaxUploadException(authenticationFailed: true);
      }
      final authentication = OAuth2(accessToken: token);
      if (!await verifyAuthentication(authentication)) {
        throw const PanoramaxUploadException(authenticationFailed: true);
      }
      await _storage.write(key: _tokenKey, value: token);
      return authentication;
    } finally {
      client.close();
    }
  }

  Future<bool> verifyAuthentication(OAuth2 authentication) async {
    final client = _client();
    try {
      await client.get<dynamic>(
        '/users/me',
        options: Options(headers: {'Authorization': authentication.getAuthorizationHeader()}),
      );
      return true;
    } on DioException catch (error) {
      if ([401, 403].contains(error.response?.statusCode)) return false;
      rethrow;
    } finally {
      client.close();
    }
  }

  Future<void> logout() => _storage.delete(key: _tokenKey);
}
