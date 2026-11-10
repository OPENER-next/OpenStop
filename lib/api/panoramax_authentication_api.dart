import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:osm_api/osm_api.dart';

import '/commons/app_config.dart';
import '/commons/panoramax_config.dart';
import 'panoramax_api.dart' show PanoramaxException;

/// Exchanges an OSM identity proof for the instance's own upload credential.
class PanoramaxAuthenticationAPI {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'panoramaxToken';

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
    final response = await _request('/auth/osm/exchange', data: {'id_token': idToken});
    final token = response.data?['jwt_token'];
    if (token is! String || token.isEmpty) {
      throw const PanoramaxException(authenticationFailed: true);
    }
    final authentication = OAuth2(accessToken: token);
    if (!await verifyAuthentication(authentication)) {
      throw const PanoramaxException(authenticationFailed: true);
    }
    await _storage.write(key: _tokenKey, value: token);
    return authentication;
  }

  Future<bool> verifyAuthentication(OAuth2 authentication) async {
    try {
      await _request('/users/me', method: 'GET', authentication: authentication);
      return true;
    } on DioException catch (error) {
      if ([401, 403].contains(error.response?.statusCode)) return false;
      rethrow;
    }
  }

  Future<void> logout() => _storage.delete(key: _tokenKey);

  Future<Response<Map<String, dynamic>>> _request(
    String path, {
    Map<String, String>? data,
    String method = 'POST',
    OAuth2? authentication,
  }) async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
    try {
      return await dio.request<Map<String, dynamic>>(
        '$kPanoramaxUrl/api$path',
        data: data,
        options: Options(
          method: method,
          followRedirects: false,
          headers: {
            'User-Agent': kAppUserAgent,
            if (authentication != null) 'Authorization': authentication.getAuthorizationHeader(),
          },
        ),
      );
    } finally {
      dio.close();
    }
  }
}
