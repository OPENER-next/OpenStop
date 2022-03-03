import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:osm_api/osm_api.dart';

import '/commons/osm_config.dart' as osm_config;


// OAuth 2 login
// A good introduction can be found here https://www.oauth.com/oauth2-servers/oauth-native-apps/

class OSMAuthenticationAPI {
  static const _config = AuthorizationServiceConfiguration(
    authorizationEndpoint: '${osm_config.osmServerUri}/oauth2/authorize',
    tokenEndpoint: '${osm_config.osmServerUri}/oauth2/token',
    endSessionEndpoint: '${osm_config.osmServerUri}/oauth2/revoke'
  );

  static const _secureStorage = FlutterSecureStorage();

  final _appAuth = FlutterAppAuth();


  OAuth2? _authentication;


  /// Get an instance of the [OSMAPI] which is either authorized or not.
  /// This depends depends on whether [login] was called successfully before or not.

  OAuth2? get authentication => _authentication;


  /// This will start the login/authentication process by opening the openstreetmap website inside a browser/webview.
  /// The future will resolve when this process has finished.
  /// If the access token was gathered successfully [isAuthenticated] should now return true.
  /// Otherwise errors might be thrown.

  Future<void> login() async {
    // Important: do NOT pass the client secret
    // The function will then automatically use PKCE for authorization.
    // AppAuth will generate a code verifier + code challenge (hash) and handle the entire requests/responses.
    // When setting up OAuth2 in OSM its important to uncheck the box that says "Confidential application",
    // otherwise PKCE authorization won't work.
    final tokenResponse = await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        osm_config.oAuth2ClientId,
        osm_config.oAuth2RedirectUri,
        serviceConfiguration: _config,
        scopes: const ['write_api', 'read_prefs']
      ),
    );

    if (tokenResponse != null) {
      final accessToken = tokenResponse.accessToken!;

      await _secureStorage.write(key: 'accessToken', value: accessToken);

      _authentication = OAuth2(
        accessToken: accessToken,
        tokenType: tokenResponse.tokenType!
      );
    }
  }


  /// Restore the previous session if one exists.
  /// This method looks for a previous access token in the storage and tries to reuse it.

  Future<void> restore() async {
    final accessToken = await _secureStorage.read(key: 'accessToken');
    if (accessToken != null) {
      _authentication = OAuth2(
        accessToken: accessToken,
      );

      if (!await verifyAuthentication()) {
        _authentication = null;
      }
    }
  }


  /// Terminates the current session by deleting the current access token.

  Future<void> logout() async {
    _authentication = null;

    await Future.wait([
      _secureStorage.delete(key: 'accessToken'),
      // OSM currently does not support token revocation (https://github.com/openstreetmap/openstreetmap-website/issues/3412)
      // appAuth.endSession(
      //   EndSessionRequest(
      //     serviceConfiguration: _config
      //   )
      // ),
    ]);
  }


  /// Verify that the current api is (still) authenticated and grants the required permissions.
  /// This can throw OSM API connection exceptions

  Future<bool> verifyAuthentication() async {
    final osmApi = OSMAPI(
      baseUrl: '${osm_config.osmServerUri}/api/0.6',
      authentication: authentication
    );

    try {
      final permissions = await osmApi.getPermissions();
      return permissions.hasAll(const ['allow_read_prefs', 'allow_write_api']);
    }
    on OSMUnauthorizedException {
      return false;
    }
    finally {
      osmApi.dispose();
    }
  }
}
