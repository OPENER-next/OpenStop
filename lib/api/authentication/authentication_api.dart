import 'package:osm_api/osm_api.dart';

import '/models/authenticated_user.dart';

/// Common interface for the services a user can log in to.

abstract class AuthenticationAPI {
  Future<OAuth2> login();

  Future<OAuth2?> restore();

  Future<void> logout();

  Future<AuthenticatedUser> user(OAuth2 authentication);
}
