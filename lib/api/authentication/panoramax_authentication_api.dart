import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:osm_api/osm_api.dart';

import '/api/authentication/authentication_api.dart';
import '/commons/app_config.dart';
import '/commons/panoramax_config.dart';
import '/models/authenticated_user.dart';

// Token login as used by the Panoramax command line tool
// The app generates a token which the user then claims on the website of the Panoramax instance.

class PanoramaxAuthenticationAPI implements AuthenticationAPI<String> {
  /// The base URL of the Panoramax instance.

  final Uri _instance;

  PanoramaxAuthenticationAPI({
    String endPoint = kPanoramaxUrl,
  }) : _instance = Uri.parse(endPoint);

  static const _secureStorage = FlutterSecureStorage();

  static const _tokenKey = 'panoramaxToken';
  // The token id is required to revoke the token on logout.
  static const _tokenIdKey = 'panoramaxTokenId';

  /// This will start the login/authentication process by opening the claim page of a new token inside a browser/webview.
  /// The future will resolve when this process has finished.
  /// If the token was claimed successfully an [OAuth2] authentication object will be returned.
  /// Otherwise errors might be thrown.

  @override
  Future<OAuth2> login() async {
    final response = await _request(
      'auth/tokens/generate',
      method: 'POST',
      queryParameters: {'description': kAppName},
    );
    final token = response.data!['jwt_token'] as String;
    final tokenId = response.data!['id'] as String;
    final claimLink = (response.data!['links'] as List).cast<Map<String, dynamic>>().firstWhere(
      (link) => link['rel'] == 'claim',
    );
    final claimUri = Uri.parse(claimLink['href'] as String);

    try {
      await FlutterWebAuth2.authenticate(
        url: claimUri
            .replace(
              queryParameters: {
                ...claimUri.queryParameters,
                'next_url': kPanoramaxCallbackUri,
              },
            )
            .toString(),
        callbackUrlScheme: kPanoramaxCallbackUrlScheme,
        options: const FlutterWebAuth2Options(
          preferEphemeral: true,
        ),
      );
    } on PlatformException catch (error) {
      // Instances without redirect support require the user to close the browser after claiming.
      if (error.code != 'CANCELED') rethrow;
    }

    await Future.wait([
      _secureStorage.write(key: _tokenKey, value: token),
      _secureStorage.write(key: _tokenIdKey, value: tokenId),
    ]);

    return OAuth2(accessToken: token);
  }

  /// Restore the previous session if one exists.
  /// This method looks for a previous token in the storage and tries to reuse it.

  @override
  Future<OAuth2?> restore() async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token != null) {
      final authentication = OAuth2(accessToken: token);

      if (await _verifyAuthentication(authentication)) {
        return authentication;
      }
    }
    return null;
  }

  /// Terminates the current session by deleting the current token.
  /// This also revokes the token from the Panoramax instance.

  @override
  Future<void> logout() async {
    final token = await _secureStorage.read(key: _tokenKey);
    final tokenId = await _secureStorage.read(key: _tokenIdKey);
    if (token != null) {
      await Future.wait([
        _secureStorage.delete(key: _tokenKey),
        _secureStorage.delete(key: _tokenIdKey),
        if (tokenId != null) _revokeToken(tokenId, OAuth2(accessToken: token)),
      ]);
    }
  }

  /// Revokes the token on the Panoramax instance.
  /// A token that was already revoked on the website is ignored.

  Future<void> _revokeToken(String tokenId, OAuth2 authentication) async {
    try {
      await _request('users/me/tokens/$tokenId', method: 'DELETE', authentication: authentication);
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode != 401 && statusCode != 403) rethrow;
    }
  }

  /// Verify that the token is (still) valid and has been claimed by a user.

  Future<bool> _verifyAuthentication(OAuth2 authentication) async {
    try {
      await _request('users/me', authentication: authentication);
      return true;
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) return false;
      rethrow;
    }
  }

  /// Method to get user details of the currently authenticated user.

  @override
  Future<AuthenticatedUser<String>> user(OAuth2 authentication) async {
    final response = await _request('users/me', authentication: authentication);
    return AuthenticatedUser(
      authentication: authentication,
      name: response.data!['name'] as String,
      id: response.data!['id'] as String,
      instance: _instance,
      // Panoramax doesn't currently have a profile page
      profileUrl: _instance.replace(
        pathSegments: [..._instance.pathSegments, 'your-pictures'],
      ),
      preferredLanguages: const [],
    );
  }

  Future<Response<Map<String, dynamic>>> _request(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? queryParameters,
    Auth? authentication,
  }) async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
    try {
      return await dio.request<Map<String, dynamic>>(
        '$_instance/api/$path',
        queryParameters: queryParameters,
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

class PanoramaxAuthenticationException implements Exception {
  const PanoramaxAuthenticationException();
}
