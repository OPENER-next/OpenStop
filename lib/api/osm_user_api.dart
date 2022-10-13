import 'package:osm_api/osm_api.dart';

import '/models/authenticated_user.dart';
import '/commons/osm_config.dart' as osm_config;


/// This class provides API calls for getting the [AuthenticatedUser] of the currently logged in user.

class OSMUserAPI {
  final OSMAPI _osmApi;

  OSMUserAPI({
    required Auth authentication,
    String endPoint = '${osm_config.osmServerUri}/api/0.6',
  }) :
    _osmApi = OSMAPI(
      authentication: authentication,
      baseUrl: endPoint,
      connectTimeout: 10000,
      receiveTimeout: 15000,
    );

  Auth get authentication => _osmApi.authentication!;


  set authentication(Auth value) => _osmApi.authentication = value;


  /// Method to get user details of the currently authenticated user.
  /// This method will throw [OSMAPI] exceptions, like an [OSMUnauthorizedException] if the user isn't authenticated any more.

  Future<AuthenticatedUser> getAuthenticatedUser() async {
    final userDetails = await _osmApi.getCurrentUserDetails();
    return AuthenticatedUser(
      authentication: authentication,
      name: userDetails.name,
      id: userDetails.id,
      preferredLanguages: userDetails.preferredLanguages,
      profileImageUrl: userDetails.profileImageUrl
    );
  }


  /// A method to terminate the api client and cleanup any open connections.
  /// This should be called inside the widgets dispose callback.

  dispose() {
    _osmApi.dispose();
  }
}
