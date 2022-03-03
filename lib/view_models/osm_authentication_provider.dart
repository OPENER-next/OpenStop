import 'package:flutter/foundation.dart';
import 'package:osm_api/osm_api.dart';

import '/api/osm_user_api.dart';
import '/api/osm_authentication_api.dart';


/// Provides the OAuth2 authentication object and details about the currently authenticated user.

class OSMAuthenticationProvider extends ChangeNotifier {

  final _osmAuthenticationApi = OSMAuthenticationAPI();


  OSMUserPrivateDetails? _userDetails;


  OSMAuthenticationProvider() {
    _init();
  }


  void _init() async {
    await _osmAuthenticationApi.restore();

    if (_osmAuthenticationApi.authentication != null) {
      final osmUserApi = OSMUserAPI(
        authentication: _osmAuthenticationApi.authentication!
      );
      try {
        _userDetails = await osmUserApi.getUserDetails();
        notifyListeners();
      }
      finally {
        osmUserApi.dispose();
      }
    }
  }


  bool get isLoggedIn => _userDetails != null;


  bool get isLoggedOut => _userDetails == null;


  OSMUserPrivateDetails? get userDetails => _userDetails;


  OAuth2? get authentication => _osmAuthenticationApi.authentication;


  void login() async {
    if (isLoggedIn) return;

    OSMUserAPI? osmUserApi;
    try {
      await _osmAuthenticationApi.login();

      osmUserApi = OSMUserAPI(
        authentication: _osmAuthenticationApi.authentication!
      );
      _userDetails = await osmUserApi.getUserDetails();

      notifyListeners();
    }
    catch (error) {
      // TODO: display or handle error
      debugPrint(error.toString());
    }
    finally {
      osmUserApi?.dispose();
    }
  }


  void logout() async {
    if (isLoggedOut) return;
    try {
      await _osmAuthenticationApi.logout();

      _userDetails = null;

      notifyListeners();
    }
    catch (error) {
      // TODO: display or handle error
      debugPrint(error.toString());
    }
  }
}
