import 'package:flutter/foundation.dart';
import 'package:osm_api/osm_api.dart';
import 'package:url_launcher/url_launcher.dart';

import '/models/authenticated_user.dart';
import '/api/osm_user_api.dart';
import '/api/osm_authentication_api.dart';
import '/commons/osm_config.dart' as osm_config;


/// Provides the OAuth2 authentication object and details about the currently authenticated user.

class OSMAuthenticatedUserProvider extends ChangeNotifier {

  final _osmAuthenticationApi = OSMAuthenticationAPI();


  AuthenticatedUser? _authenticatedUser;


  OSMAuthenticatedUserProvider() {
    _init();
  }


  void _init() async {
    final authentication = await _osmAuthenticationApi.restore();
    if (authentication != null) {
      try {
        _authenticatedUser = await _getAuthenticatedUser(authentication);
        notifyListeners();
      }
      catch (error) {
        // TODO: display or handle error
        debugPrint(error.toString());
      }
    }
  }


  bool get isLoggedIn => _authenticatedUser != null;


  bool get isLoggedOut => _authenticatedUser == null;


  AuthenticatedUser? get authenticatedUser => _authenticatedUser;


  Future<void> login() async {
    if (isLoggedIn) return;
    try {
      final authentication = await _osmAuthenticationApi.login();
      _authenticatedUser = await _getAuthenticatedUser(authentication);
      notifyListeners();
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

      _authenticatedUser = null;

      notifyListeners();
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
        Uri.https(osm_config.osmServer, '/user/${_authenticatedUser!.name}'),
        mode: LaunchMode.externalApplication,
      );
    }
    catch (error) {
      debugPrint(error.toString());
      return false;
    }
  }


  Future<AuthenticatedUser> _getAuthenticatedUser(OAuth2 authentication) async {
    final osmUserApi = OSMUserAPI(
      authentication: authentication
    );

    final AuthenticatedUser user;
    try {
      user = await osmUserApi.getAuthenticatedUser();
    }
    catch (error) {
      rethrow;
    }
    finally {
      osmUserApi.dispose();
    }
    return user;
  }
}
