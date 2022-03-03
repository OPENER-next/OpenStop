import 'package:osm_api/osm_api.dart';

/// A class holding information about an authenticated OpenStreetMap user.

class AuthenticatedUser {
  final OAuth2 oAuth2Authentication;

  final String name;

  final int id;

  final String? profileImageUrl;

  final List<String> preferredLanguages;

  AuthenticatedUser({
    required this.oAuth2Authentication,
    required this.name,
    required this.id,
    required this.preferredLanguages,
    this.profileImageUrl
  });
}
