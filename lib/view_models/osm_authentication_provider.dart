import 'package:flutter/foundation.dart';
import 'package:osm_api/osm_api.dart';

import '/api/osm_authentication_manager.dart';


class OSMAuthenticationProvider extends ChangeNotifier {

  final _authenticationManager = OSMAuthenticationManager();

  OSMUserPrivateDetails? _userDetails;


  OSMAuthenticationProvider() {
    _init();
  }


  void _init() async {
    await _authenticationManager.restore();
    if (isLoggedIn) {
      _userDetails = await _authenticationManager.osmApi.getCurrentUserDetails();
      notifyListeners();
    }
  }


  bool get isLoggedIn => _authenticationManager.isAuthenticated;


  bool get isLoggedOut => !isLoggedIn;


  OSMUserPrivateDetails? get userDetails => _userDetails;


  void login() async {
    if (isLoggedIn) return;
    try {
      await _authenticationManager.login();

      _userDetails = await _authenticationManager.osmApi.getCurrentUserDetails();

      notifyListeners();
    }
    catch (error) {
      // TODO: display or handle error
      debugPrint(error.toString());
    }
  }


  void logout() async {
    if (isLoggedOut) return;
    try {
      await _authenticationManager.logout();

      _userDetails = null;

      notifyListeners();
    }
    catch (error) {
      // TODO: display or handle error
      debugPrint(error.toString());
    }
  }


  @override
  void dispose() {
    _authenticationManager.dispose();
    super.dispose();
  }
}
