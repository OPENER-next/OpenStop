import 'package:flutter/foundation.dart';
import 'package:flutter_mvvm_architecture/base.dart';
import 'package:mobx/mobx.dart';
import 'package:osm_api/osm_api.dart';
import 'package:url_launcher/url_launcher.dart';

import '/api/authentication_api.dart';
import '/commons/osm_config.dart';
import '/models/authenticated_user.dart';

/// Provides login/logout method and details about the currently authenticated user.

class UserAccountService extends Service {
  late final _authenticationApi = AuthenticationAPI(
    onAuthenticationChanged: _onAuthenticationChanged,
  );

  final _authenticatedUser = Observable<AuthenticatedUser?>(null);

  UserAccountService() {
    _init();
  }

  Future<void> _init() async {
    final authentication = await _authenticationApi.restore();
    if (authentication != null) {
      try {
        final user = await _getAuthenticatedUser(authentication);
        runInAction(() => _authenticatedUser.value = user);
      } catch (error) {
        // TODO: display or handle error
        debugPrint(error.toString());
      }
    }
  }

  late final _isLoggedIn = Computed(() => authenticatedUser != null);

  bool get isLoggedIn => _isLoggedIn.value;

  late final _isLoggedOut = Computed(() => authenticatedUser == null);

  bool get isLoggedOut => _isLoggedOut.value;

  AuthenticatedUser? get authenticatedUser => _authenticatedUser.value;

  void _onAuthenticationChanged(OAuth2? authentication) {
    final user = authenticatedUser;
    runInAction(() {
      if (authentication == null) {
        _authenticatedUser.value = null;
      } else if (user != null) {
        _authenticatedUser.value = AuthenticatedUser(
          authentication: authentication,
          name: user.name,
          id: user.id,
          preferredLanguages: user.preferredLanguages,
          profileImageUrl: user.profileImageUrl,
        );
      }
    });
  }

  Future<void> login() async {
    if (isLoggedIn) return;
    try {
      final authentication = await _authenticationApi.login();
      final user = await _getAuthenticatedUser(authentication);
      runInAction(() => _authenticatedUser.value = user);
    } catch (error) {
      // TODO: display or handle error
      debugPrint(error.toString());
    }
  }

  Future<void> logout() async {
    if (isLoggedOut) return;
    try {
      await _authenticationApi.logout();
      runInAction(() => _authenticatedUser.value = null);
    } catch (error) {
      // TODO: display or handle error
      debugPrint(error.toString());
    }
  }

  Future<String> authorizePhotoUpload() => _authenticationApi.authenticateForUpload(
    osmUserId: _authenticatedUser.value!.id,
  );

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
