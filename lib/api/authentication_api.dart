import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:osm_api/osm_api.dart';

import 'osm_authentication_api.dart';
import 'panoramax_api.dart';
import 'panoramax_authentication_api.dart';

/// Coordinates OSM login and optional, consented Panoramax authentication.
/// Ordinary login does not share the user's identity with the photo service.
class AuthenticationAPI {
  final OSMAuthenticationAPI osm;
  final PanoramaxAuthenticationAPI panoramax;
  final void Function(OAuth2?)? _onAuthenticationChanged;

  AuthenticationAPI({
    OSMAuthenticationAPI? osm,
    PanoramaxAuthenticationAPI? panoramax,
    void Function(OAuth2?)? onAuthenticationChanged,
    List<String> permissions = const ['write_api', 'read_prefs', 'openid'],
  }) : osm = osm ?? OSMAuthenticationAPI(permissions: permissions),
       panoramax = panoramax ?? PanoramaxAuthenticationAPI(),
       _onAuthenticationChanged = onAuthenticationChanged;

  List<String> get permissions => osm.permissions;

  Future<OAuth2> login({bool authorizePanoramax = false, int? expectedUserId}) async {
    await panoramax.logout();
    final authentication = await osm.login();
    if (authorizePanoramax) {
      final proof = osm.idToken;
      if (proof == null || expectedUserId != null && proof.subject != '$expectedUserId') {
        // Do not restore a different account after a failed upload reauthorization.
        try {
          await osm.logout();
        } catch (_) {
          // The in-memory proof is cleared even if remote revocation fails.
        }
        _onAuthenticationChanged?.call(null);
        throw const PanoramaxUploadException(authenticationFailed: true);
      }
      _onAuthenticationChanged?.call(authentication);
      await panoramax.authenticate(proof);
    } else {
      _onAuthenticationChanged?.call(authentication);
    }
    return authentication;
  }

  /// Called only after the publication and identity-sharing consent prompt.
  Future<String> authenticateForUpload({required int osmUserId}) async {
    final existing = await panoramax.restore(osmUserId: osmUserId);
    if (existing != null) return existing;
    final proof = osm.idToken;
    if (proof != null && !proof.isExpired && proof.subject == '$osmUserId') {
      return panoramax.authenticate(proof);
    }
    await login(authorizePanoramax: true, expectedUserId: osmUserId);
    return (await panoramax.restore(osmUserId: osmUserId)) ??
        (throw const PanoramaxUploadException(authenticationFailed: true));
  }

  Future<OAuth2?> restore() async {
    // Remove proofs persisted by older versions; new proofs remain in memory.
    await const FlutterSecureStorage().delete(key: 'osmIdToken');
    return osm.restore();
  }

  Future<void> logout() async {
    await panoramax.logout();
    await osm.logout();
    _onAuthenticationChanged?.call(null);
  }

  Future<bool> verifyAuthentication(OAuth2 authentication) =>
      osm.verifyAuthentication(authentication);
}
