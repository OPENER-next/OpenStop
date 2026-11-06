import 'package:flutter/foundation.dart';
import 'package:flutter_mvvm_architecture/base.dart';
import 'package:mobx/mobx.dart';
import 'package:osm_api/osm_api.dart';
import 'package:url_launcher/url_launcher.dart';

import '/api/osm_authentication_api.dart';
import '/api/panoramax_api.dart' show PanoramaxUploadException;
import '/api/panoramax_authentication_api.dart';
import '/commons/osm_config.dart';
import '/models/authenticated_user.dart';

/// Owns the OSM session and its optional, consented Panoramax authentication.
class UserAccountService extends Service {
  final OSMAuthenticationAPI _osmAuthentication;
  final PanoramaxAuthenticationAPI _panoramaxAuthentication;
  final _authenticatedUser = Observable<AuthenticatedUser?>(null);
  late final Future<void> _initializing;
  Future<void> _sessionOperation = Future.value();

  UserAccountService({
    OSMAuthenticationAPI? osmAuthentication,
    PanoramaxAuthenticationAPI? panoramaxAuthentication,
  }) : _osmAuthentication = osmAuthentication ?? OSMAuthenticationAPI(),
       _panoramaxAuthentication = panoramaxAuthentication ?? PanoramaxAuthenticationAPI() {
    _initializing = _init();
  }

  Future<void> _init() async {
    try {
      final authentication = await _osmAuthentication.restore();
      if (authentication == null) {
        await _panoramaxAuthentication.logout();
        return;
      }
      final user = await _getAuthenticatedUser(authentication);
      runInAction(() => _authenticatedUser.value = user);
      try {
        final photoAuthentication = await _panoramaxAuthentication.restore();
        runInAction(
          () => _authenticatedUser.value = user.withPanoramaxAuthentication(photoAuthentication),
        );
      } catch (error) {
        // A photo service outage does not prevent ordinary OSM editing.
        debugPrint(error.toString());
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  late final _isLoggedIn = Computed(() => authenticatedUser != null);
  bool get isLoggedIn => _isLoggedIn.value;
  late final _isLoggedOut = Computed(() => authenticatedUser == null);
  bool get isLoggedOut => _isLoggedOut.value;
  AuthenticatedUser? get authenticatedUser => _authenticatedUser.value;

  Future<void> _login() async {
    // Clear the old photo credential before OSM can write a different session.
    await _panoramaxAuthentication.logout();
    runInAction(() => _authenticatedUser.value = null);
    final authentication = await _osmAuthentication.login();
    final user = await _getAuthenticatedUser(authentication);
    runInAction(() => _authenticatedUser.value = user);
  }

  // Serialize session changes so an exchange cannot restore credentials after logout.
  Future<void> _changeSession(Future<void> Function() operation) {
    final next = _sessionOperation.then((_) => operation());
    _sessionOperation = next.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return next;
  }

  Future<void> login() => _changeSession(() async {
    await _initializing;
    if (isLoggedIn) return;
    try {
      await _login();
    } catch (error) {
      debugPrint(error.toString());
    }
  });

  Future<void> logout() => _changeSession(() async {
    await _initializing;
    try {
      await _panoramaxAuthentication.logout();
      await _osmAuthentication.logout();
    } catch (error) {
      debugPrint(error.toString());
    } finally {
      runInAction(() => _authenticatedUser.value = null);
    }
  });

  bool get _hasFreshIdentityProof {
    final payload = _osmAuthentication.idToken?.payload;
    final expiry = payload is Map ? payload['exp'] : null;
    return expiry is num &&
        DateTime.fromMillisecondsSinceEpoch(
          (expiry * 1000).toInt(),
          isUtc: true,
        ).isAfter(DateTime.now().toUtc().add(const Duration(seconds: 30)));
  }

  /// Called only after publication and identity-sharing consent.
  Future<void> authorizePhotoUpload() => _changeSession(() async {
    await _initializing;
    final user = authenticatedUser;
    if (user == null) throw const PanoramaxUploadException(authenticationFailed: true);
    final existing = user.panoramaxAuthentication;
    if (existing != null && await _panoramaxAuthentication.verifyAuthentication(existing)) return;
    await _panoramaxAuthentication.logout();
    runInAction(() => _authenticatedUser.value = user.withPanoramaxAuthentication(null));
    if (!_hasFreshIdentityProof) await _login();
    final proof = _osmAuthentication.encodedIdToken;
    if (proof == null) throw const PanoramaxUploadException(authenticationFailed: true);
    final authentication = await _panoramaxAuthentication.authenticate(proof);
    runInAction(
      () =>
          _authenticatedUser.value = authenticatedUser!.withPanoramaxAuthentication(authentication),
    );
  });

  Future<bool> openUserProfile() async {
    if (isLoggedOut) return false;
    try {
      return await launchUrl(
        Uri.https(kOSMServer, '/user/${_authenticatedUser.value!.name}'),
        mode: LaunchMode.externalApplication,
      );
    } catch (error) {
      debugPrint(error.toString());
      return false;
    }
  }

  /// Method to get user details of the currently authenticated user.
  /// This method will throw [OSMAPI] exceptions, like an [OSMUnauthorizedException] if the user isn't authenticated any more.

  Future<AuthenticatedUser> _getAuthenticatedUser(OAuth2 authentication) async {
    final osmApi = DefaultOSMAPI(
      authentication: authentication,
    );

    final AuthenticatedUser user;
    try {
      final userDetails = await osmApi.getCurrentUserDetails();
      user = AuthenticatedUser(
        authentication: authentication,
        name: userDetails.name,
        id: userDetails.id,
        preferredLanguages: userDetails.preferredLanguages,
        profileImageUrl: userDetails.profileImageUrl,
      );
    } catch (error) {
      rethrow;
    } finally {
      osmApi.dispose();
    }
    return user;
  }
}
