import 'package:osm_api/osm_api.dart';

import '/models/authenticated_user.dart';

/// Common interface for the services a user can log in to.
///
/// [T] is the type of the user id, see [AuthenticatedUser].

abstract class AuthenticationAPI<T> {
  Future<OAuth2> login();

  Future<OAuth2?> restore();

  Future<void> logout();

  Future<AuthenticatedUser<T>> user(OAuth2 authentication);
}
