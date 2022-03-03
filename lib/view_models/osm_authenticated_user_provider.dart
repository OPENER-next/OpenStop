import 'package:flutter/foundation.dart';
import 'package:osm_api/osm_api.dart';

import '/models/authenticated_user.dart';
import '/api/osm_user_api.dart';
import '/api/osm_authentication_api.dart';


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


  void login() async {
    if (isLoggedIn) return;
    try {
      final authentication = await _osmAuthenticationApi.login();

      if (authentication != null) {
        _authenticatedUser = await _getAuthenticatedUser(authentication);
        notifyListeners();
      }
    }
    catch (error) {
      // TODO: display or handle error
      debugPrint(error.toString());
    }
  }


  void logout() async {
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


  Future<AuthenticatedUser> _getAuthenticatedUser(OAuth2 authentication) async {
    final osmUserApi = OSMUserAPI(
      authentication: authentication
    );

    final OSMUserPrivateDetails userDetails;
    try {
      userDetails = await osmUserApi.getUserDetails();
    }
    catch (error) {
      rethrow;
    }
    finally {
      osmUserApi.dispose();
    }

    return AuthenticatedUser(
      oAuth2Authentication: authentication,
      name: userDetails.name,
      id: userDetails.id,
      preferredLanguages: userDetails.preferredLanguages,
      profileImageUrl: userDetails.profileImageUrl
    );
  }
}
