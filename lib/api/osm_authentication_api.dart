import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:osm_api/osm_api.dart';

import '/commons/app_config.dart' as app_config;
import '/commons/osm_config.dart' as osm_config;


// OAuth 2 login
// A good introduction can be found here https://www.oauth.com/oauth2-servers/oauth-native-apps/

class OSMAuthenticationAPI {

  final List<String> permissions;

  OSMAuthenticationAPI({
    this.permissions = const [
      'write_api',
      'read_prefs',
    ],
  });

  static const _secureStorage = FlutterSecureStorage();

  static const _authorizationEndpoint = '/oauth2/authorize';
  static const _tokenEndpoint = '/oauth2/token';
  static const _revokeEndpoint = '/oauth2/revoke';

  /// This will start the login/authentication process by opening the openstreetmap website inside a browser/webview.
  /// The future will resolve when this process has finished.
  /// If the access token was gathered successfully an [OAuth2] authentication object will be returned.
  /// Otherwise errors might be thrown.

  Future<OAuth2> login() async {
    final authUri = Uri.https(osm_config.osmServer, _authorizationEndpoint, {
      'response_type': 'code',
      'client_id': osm_config.oAuth2ClientId,
      'redirect_uri': osm_config.oAuth2RedirectUri,
      'scope': permissions.join(' '),
    });

    // Important: do NOT pass the client secret
    // Instead use PKCE for authorization (code verifier)
    // When setting up OAuth2 in OSM its important to uncheck the box that says "Confidential application",
    // otherwise PKCE authorization won't work.
    final result = await FlutterWebAuth.authenticate(
      url: authUri.toString(),
      callbackUrlScheme: app_config.appCallbackUrlScheme,
      preferEphemeral: true,
    );
    final code = Uri.parse(result).queryParameters['code'];

    final dio = Dio();
    final tokenResponse = await dio.post<Map<String, String>>(
      Uri.https(osm_config.osmServer, _tokenEndpoint).toString(),
      data: {
        'client_id': osm_config.oAuth2ClientId,
        'redirect_uri': osm_config.oAuth2RedirectUri,
        'grant_type': 'authorization_code',
        'code': code,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    dio.close();

    final accessToken = tokenResponse.data?['access_token'];
    final tokenType = tokenResponse.data?['token_type'];

    if (accessToken == null || tokenType == null) {
      throw Exception('Failed to retrieve OAuth2 access token.');
    }

    await _secureStorage.write(key: 'accessToken', value: accessToken);

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
    final accessToken = await _secureStorage.read(key: 'accessToken');
    if (accessToken != null) {
      final dio = Dio();
      try {
        await Future.wait([
          // remove token from storage
          _secureStorage.delete(key: 'accessToken'),
          // revoke the token from the osm server
          // this way any granted permissions by the user are revoked
          // the user has to authorize the app again on the next login
          dio.post<void>(
            Uri.https(osm_config.osmServer, _revokeEndpoint).toString(),
            data: {
              'token': accessToken,
              'token_type_hint': 'access_token',
              'client_id': osm_config.oAuth2ClientId,
            },
            options: Options(
              contentType: Headers.formUrlEncodedContentType,
            ),
          ),
        ]);
      }
      finally {
        dio.close();
      }
    }
  }


  /// Verify that the current api is (still) authenticated and grants the required permissions.
  /// This can throw OSM API connection exceptions

  Future<bool> verifyAuthentication(OAuth2 authentication) async {
    final osmApi = OSMAPI(
      baseUrl: Uri.https(osm_config.osmServer, '/api/0.6').toString(),
      authentication: authentication,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    );

    try {
      final permissions = await osmApi.getPermissions();
      return permissions.hasAll(const [
        OSMPermissions.READ_USER_PREFERENCES,
        OSMPermissions.WRITE_MAP,
      ]);
    }
    on OSMUnauthorizedException {
      return false;
    }
    finally {
      osmApi.dispose();
    }
  }
}
