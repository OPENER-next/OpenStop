import 'package:flutter/foundation.dart';
import 'package:flutter_mvvm_architecture/base.dart';
import 'package:mobx/mobx.dart';
import 'package:osm_api/osm_api.dart';
import 'package:url_launcher/url_launcher.dart';

import '/api/osm_authentication_api.dart';
import '/commons/osm_config.dart' as osm_config;
import '/models/authenticated_user.dart';


/// Provides login/logout method and details about the currently authenticated user.

class UserAccountService extends Service {

  final _osmAuthenticationApi = OSMAuthenticationAPI();

  final _authenticatedUser = Observable<AuthenticatedUser?>(null);

  UserAccountService() {
    _init();
  }

  Future<void> _init() async {
    final authentication = await _osmAuthenticationApi.restore();
    if (authentication != null) {
      try {
        final user =  await _getAuthenticatedUser(authentication);
        runInAction(() => _authenticatedUser.value = user);
      }
      catch (error) {
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


  Future<void> login() async {
    if (isLoggedIn) return;
    try {
      final authentication = await _osmAuthenticationApi.login();
      final user =  await _getAuthenticatedUser(authentication);
      runInAction(() => _authenticatedUser.value = user);
    }
    catch (error) {
      // TODO: display or handle error
      debugPrint(error.toString());
    }
  }


  Future<void> logout() async {
    if (isLoggedOut) return;
    try {
      await _osmAuthenticationApi.logout();
      runInAction(() => _authenticatedUser.value = null);
    }
    catch (error) {
      // TODO: display or handle error
      debugPrint(error.toString());
    }
  }


  Future<bool> openUserProfile() async {
    if (isLoggedOut) return false;
    try {
      return await launchUrl(
        Uri.https(osm_config.osmServer, '/user/${_authenticatedUser.value!.name}'),
        mode: LaunchMode.externalApplication,
      );
    }
    catch (error) {
      debugPrint(error.toString());
      return false;
    }
  }

  /// Method to get user details of the currently authenticated user.
  /// This method will throw [OSMAPI] exceptions, like an [OSMUnauthorizedException] if the user isn't authenticated any more.

  Future<AuthenticatedUser> _getAuthenticatedUser(OAuth2 authentication) async {
    final osmApi = OSMAPI(
      authentication: authentication,
      baseUrl: 'https://${osm_config.osmServer}/api/0.6',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    );

    final AuthenticatedUser user;
    try {
      final userDetails = await osmApi.getCurrentUserDetails();
      user = AuthenticatedUser(
        authentication: authentication,
        name: userDetails.name,
        id: userDetails.id,
        preferredLanguages: userDetails.preferredLanguages,
        profileImageUrl: userDetails.profileImageUrl
      );
    }
    catch (error) {
      rethrow;
    }
    finally {
      osmApi.dispose();
    }
    return user;
  }
}
