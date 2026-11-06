import 'package:osm_api/osm_api.dart';

/// A class holding information about an authenticated OpenStreetMap user.

class AuthenticatedUser {
  final Auth authentication;

  final OAuth2? panoramaxAuthentication;

  final String name;

  final int id;

  final String? profileImageUrl;

  final List<String> preferredLanguages;

  const AuthenticatedUser({
    required this.authentication,
    required this.name,
    required this.id,
    required this.preferredLanguages,
    this.panoramaxAuthentication,
    this.profileImageUrl,
  });

  AuthenticatedUser withPanoramaxAuthentication(OAuth2? value) => AuthenticatedUser(
    authentication: authentication,
    panoramaxAuthentication: value,
    name: name,
    id: id,
    preferredLanguages: preferredLanguages,
    profileImageUrl: profileImageUrl,
  );
}
