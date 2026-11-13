import 'package:flutter/foundation.dart';
import 'package:flutter_mvvm_architecture/base.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:osm_api/osm_api.dart';
import 'package:url_launcher/url_launcher.dart';

import '/api/osm_authentication_api.dart';
import '/api/panoramax_authentication_api.dart';
import '/api/preferences_service.dart';
import '/commons/osm_config.dart';
import '/models/authenticated_user.dart';

/// Owns the OSM session and its optional, consented Panoramax authentication.
class UserAccountService extends Service {
  final _osmAuthentication = OSMAuthenticationAPI();
  final _panoramaxAuthentication = PanoramaxAuthenticationAPI();
  final _authenticatedUser = Observable<AuthenticatedUser?>(null);
  bool _initializing = true;

  PreferencesService get _preferences => GetIt.I.get<PreferencesService>();

  bool get hasPhotoPublicationConsent => _preferences.hasPhotoPublicationConsent;

  UserAccountService() {
    _init();
  }

  Future<void> _init() async {
    try {
      final authentication = await _osmAuthentication.restore();
      if (authentication == null) {
        await _panoramaxAuthentication.logout();
        _preferences.hasPhotoPublicationConsent = false;
        return;
      }
      OAuth2? photoAuthentication;
      try {
        photoAuthentication = await _panoramaxAuthentication.restore();
      } catch (error) {
        // A photo service outage does not prevent ordinary OSM editing.
        debugPrint(error.toString());
      }
      final user = await _getAuthenticatedUser(authentication, photoAuthentication);
      runInAction(() => _authenticatedUser.value = user);
    } catch (error) {
      debugPrint(error.toString());
    } finally {
      _initializing = false;
    }
  }

  late final _isLoggedIn = Computed(() => authenticatedUser != null);

  bool get isLoggedIn => _isLoggedIn.value;

  late final _isLoggedOut = Computed(() => authenticatedUser == null);

  bool get isLoggedOut => _isLoggedOut.value;

  AuthenticatedUser? get authenticatedUser => _authenticatedUser.value;

  /// [photoConsent] records an explicit acceptance for the account used to log in.
  /// Photo authentication requires that acceptance or the current account's saved consent.
  Future<void> login({bool withPanoramax = false, bool photoConsent = false}) async {
    if (_initializing || (isLoggedIn && !withPanoramax)) return;
    try {
      final existing = authenticatedUser;
      if (withPanoramax &&
          (hasPhotoPublicationConsent || photoConsent) &&
          existing?.isAuthenticatedWithPanoramax == true &&
          await _panoramaxAuthentication.verifyAuthentication(existing!.panoramaxAuthentication!)) {
        if (photoConsent) _preferences.hasPhotoPublicationConsent = true;
        return;
      }
      final previousConsent = hasPhotoPublicationConsent;
      // A newly stored OSM session must not inherit another account's consent.
      _preferences.hasPhotoPublicationConsent = false;
      await _panoramaxAuthentication.logout();
      final result = await _osmAuthentication.login();
      final user = await _getAuthenticatedUser(result.auth);
      if (photoConsent || (existing?.id == user.id && previousConsent)) {
        _preferences.hasPhotoPublicationConsent = true;
      }
      OAuth2? photoAuthentication;
      if (withPanoramax && hasPhotoPublicationConsent) {
        try {
          final proof = result.idToken;
          if (proof == null) throw const PanoramaxAuthenticationException();
          photoAuthentication = await _panoramaxAuthentication.authenticate(proof);
        } catch (_) {
          // Keep the new OSM session usable if the optional photo exchange fails.
          runInAction(() => _authenticatedUser.value = user);
          rethrow;
        }
      }
      runInAction(
        () =>
            _authenticatedUser.value = user.copyWith(panoramaxAuthentication: photoAuthentication),
      );
    } catch (error) {
      debugPrint(error.toString());
      if (withPanoramax) rethrow;
    }
  }

  Future<void> logout() async {
    if (_initializing || isLoggedOut) return;
    try {
      _preferences.hasPhotoPublicationConsent = false;
      await Future.wait([
        _panoramaxAuthentication.logout(),
        _osmAuthentication.logout(),
      ]);
      runInAction(() => _authenticatedUser.value = null);
    } catch (error) {
      debugPrint(error.toString());
    }
  }

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

  Future<AuthenticatedUser> _getAuthenticatedUser(
    OAuth2 authentication, [
    OAuth2? panoramaxAuthentication,
  ]) async {
    final osmApi = DefaultOSMAPI(
      authentication: authentication,
    );

    final AuthenticatedUser user;
    try {
      final userDetails = await osmApi.getCurrentUserDetails();
      user = AuthenticatedUser(
        authentication: authentication,
        panoramaxAuthentication: panoramaxAuthentication,
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
