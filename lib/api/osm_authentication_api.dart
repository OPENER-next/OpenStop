import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:osm_api/osm_api.dart';

import '/commons/app_config.dart';
import '/commons/osm_config.dart';
import '/commons/panoramax_config.dart';

// OAuth 2 login
// A good introduction can be found here https://www.oauth.com/oauth2-servers/oauth-native-apps/

class OSMAuthenticationAPI {
  final List<String> permissions;

  OSMAuthenticationAPI({
    this.permissions = const [
      'write_api',
      'read_prefs',
      'openid',
    ],
  });

  static const _secureStorage = FlutterSecureStorage();
  static const _identityTokenKey = 'osmIdToken';

  static String _randomValue() => base64UrlEncode(
    List<int>.generate(32, (_) => Random.secure().nextInt(256)),
  ).replaceAll('=', '');

  /// Reauthorize only when the current user's stored proof is missing or expired.
  Future<String> identityTokenForUpload({required int expectedUserId}) async {
    final stored = await _secureStorage.read(key: _identityTokenKey);
    if (stored != null) {
      try {
        final identity = _OSMIdentityToken.parse(stored);
        if (!identity.isExpired && identity.subject == '$expectedUserId') return stored;
      } on FormatException {
        // Old or malformed proofs require a fresh authorization.
      }
    }
    await login(expectedUserId: expectedUserId);
    return (await _secureStorage.read(key: _identityTokenKey))!;
  }

  static const _authorizationEndpoint = '/oauth2/authorize';
  static const _tokenEndpoint = '/oauth2/token';
  static const _revokeEndpoint = '/oauth2/revoke';

  /// This will start the login/authentication process by opening the openstreetmap website inside a browser/webview.
  /// The future will resolve when this process has finished.
  /// If the access token was gathered successfully an [OAuth2] authentication object will be returned.
  /// Otherwise errors might be thrown.

  Future<OAuth2> login({int? expectedUserId}) async {
    final state = _randomValue();
    final nonce = _randomValue();
    final redirectUri = Uri.parse(kOAuth2RedirectUri);
    final authUri = Uri.https(kOSMServer, _authorizationEndpoint, {
      'response_type': 'code',
      'client_id': kOAuth2ClientId,
      'redirect_uri': kOAuth2RedirectUri,
      'scope': permissions.join(' '),
      'state': state,
      'nonce': nonce,
    });

    // Important: do NOT pass the client secret
    // Instead use PKCE for authorization (code verifier)
    // When setting up OAuth2 in OSM its important to uncheck the box that says "Confidential application",
    // otherwise PKCE authorization won't work.
    final result = await FlutterWebAuth2.authenticate(
      url: authUri.toString(),
      callbackUrlScheme: kAppCallbackUrlScheme,
      options: const FlutterWebAuth2Options(
        preferEphemeral: true,
        httpsHost: kAppCallbackUrlHost,
        httpsPath: kAppCallbackUrlPath,
      ),
    );
    final callback = Uri.parse(result);
    if (callback.scheme != redirectUri.scheme ||
        callback.host != redirectUri.host ||
        callback.path != redirectUri.path ||
        callback.queryParameters['state'] != state) {
      throw const FormatException('Unexpected OSM authorization callback');
    }
    final code = callback.queryParameters['code'];
    if (code == null) {
      throw Exception('Failed to retrieve OAuth2 code.');
    }

    final tokenResponse = await _request(
      Uri.https(kOSMServer, _tokenEndpoint).toString(),
      {
        'client_id': kOAuth2ClientId,
        'redirect_uri': kOAuth2RedirectUri,
        'grant_type': 'authorization_code',
        'code': code,
      },
    );

    final accessToken = tokenResponse.data?['access_token'];
    final tokenType = tokenResponse.data?['token_type'];

    if (accessToken == null || tokenType == null) {
      throw Exception('Failed to retrieve OAuth2 access token.');
    }

    final idToken = tokenResponse.data?['id_token'];
    if (permissions.contains('openid')) {
      if (idToken is! String) throw const FormatException('OSM did not return an identity proof');
      final identity = _OSMIdentityToken.parse(idToken);
      if (identity.isExpired ||
          identity.nonce != nonce ||
          expectedUserId != null && identity.subject != '$expectedUserId') {
        throw const FormatException('OSM identity does not match the requested session');
      }
    }

    // Never leave a previous account's identity or upload credential attached.
    await _secureStorage.delete(key: _identityTokenKey);
    if (expectedUserId == null) {
      await _secureStorage.delete(key: kPanoramaxTokenKey);
      await _secureStorage.delete(key: kPanoramaxAccountKey);
    }
    await _secureStorage.write(key: 'accessToken', value: accessToken);
    if (idToken is String) await _secureStorage.write(key: _identityTokenKey, value: idToken);

    return OAuth2(
      accessToken: accessToken,
      tokenType: tokenType,
    );
  }

  /// Restore the previous session if one exists.
  /// This method looks for a previous access token in the storage and tries to reuse it.

  Future<OAuth2?> restore() async {
    final accessToken = await _secureStorage.read(key: 'accessToken');
    if (accessToken != null) {
      final authentication = OAuth2(
        accessToken: accessToken,
      );

      if (await verifyAuthentication(authentication)) {
        return authentication;
      }
    }
    return null;
  }

  /// Terminates the current session by deleting the current access token.
  /// This also revokes the authentication token from the server.

  Future<void> logout() async {
    await _secureStorage.delete(key: _identityTokenKey);
    await _secureStorage.delete(key: kPanoramaxTokenKey);
    await _secureStorage.delete(key: kPanoramaxAccountKey);
    final accessToken = await _secureStorage.read(key: 'accessToken');
    if (accessToken != null) {
      await Future.wait([
        // remove token from storage
        _secureStorage.delete(key: 'accessToken'),
        // revoke the token from the osm server
        // this way any granted permissions by the user are revoked
        // the user has to authorize the app again on the next login
        _request(
          Uri.https(kOSMServer, _revokeEndpoint).toString(),
          {
            'token': accessToken,
            'token_type_hint': 'access_token',
            'client_id': kOAuth2ClientId,
          },
        ),
      ]);
    }
  }

  /// Verify that the current api is (still) authenticated and grants the required permissions.
  /// This can throw OSM API connection exceptions

  Future<bool> verifyAuthentication(OAuth2 authentication) async {
    final osmApi = DefaultOSMAPI(
      authentication: authentication,
    );
    try {
      final permissions = await osmApi.getPermissions();
      return permissions.hasAll(const [
        OSMPermissions.READ_USER_PREFERENCES,
        OSMPermissions.WRITE_MAP,
      ]);
    } on OSMUnauthorizedException {
      return false;
    } finally {
      osmApi.dispose();
    }
  }

  Future<Response<Map<String, dynamic>>> _request(
    String uri,
    Map<String, String> data,
  ) async {
    final dio = Dio();
    try {
      return await dio.post<Map<String, dynamic>>(
        uri,
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'User-Agent': kAppUserAgent,
          },
        ),
      );
    } finally {
      dio.close();
    }
  }
}

/// Inspected locally to decide whether to submit a proof. The exchange service
/// must verify the signature using OSM's public keys before trusting identity.
class _OSMIdentityToken {
  final String subject;
  final DateTime expiresAt;
  final String? nonce;

  _OSMIdentityToken(this.subject, this.expiresAt, this.nonce);

  factory _OSMIdentityToken.parse(String encoded) {
    final parts = encoded.split('.');
    if (parts.length != 3) throw const FormatException('Invalid OSM identity proof');
    final claims = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
    if (claims is! Map<String, dynamic>) throw const FormatException('Invalid OSM identity claims');
    final audience = claims['aud'];
    final subject = claims['sub'];
    final expiry = claims['exp'];
    if (claims['iss'] != 'https://$kOSMServer' ||
        !(audience == kOAuth2ClientId || audience is List && audience.contains(kOAuth2ClientId)) ||
        subject is! String ||
        !RegExp(r'^[1-9][0-9]*$').hasMatch(subject) ||
        expiry is! int ||
        claims['nonce'] != null && claims['nonce'] is! String) {
      throw const FormatException('Unexpected OSM identity claims');
    }
    return _OSMIdentityToken(
      subject,
      DateTime.fromMillisecondsSinceEpoch(expiry * 1000, isUtc: true),
      claims['nonce'] as String?,
    );
  }

  bool get isExpired => !expiresAt.isAfter(DateTime.now().toUtc().add(const Duration(seconds: 30)));
}
