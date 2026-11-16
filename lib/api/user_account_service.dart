import 'package:flutter/foundation.dart';
import 'package:flutter_mvvm_architecture/base.dart';
import 'package:mobx/mobx.dart';

import '/api/authentication/authentication_api.dart';
import '/models/authenticated_user.dart';

/// Provides login/logout method and details about the currently authenticated user.

class UserAccountService<T extends AuthenticationAPI> extends Service {
  final T _authenticationApi;

  final _authenticatedUser = Observable<AuthenticatedUser?>(null);

  UserAccountService(this._authenticationApi) {
    _init();
  }

  Future<void> _init() async {
    final authentication = await _authenticationApi.restore();
    if (authentication != null) {
      try {
        final user = await _authenticationApi.user(authentication);
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

  Future<void> login() async {
    if (isLoggedIn) return;
    try {
      final authentication = await _authenticationApi.login();
      final user = await _authenticationApi.user(authentication);
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
}
