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

  bool get isAuthenticatedWithPanoramax => panoramaxAuthentication != null;

  AuthenticatedUser copyWith({
    Auth? authentication,
    OAuth2? panoramaxAuthentication,
    String? name,
    int? id,
    String? profileImageUrl,
    List<String>? preferredLanguages,
  }) => AuthenticatedUser(
    authentication: authentication ?? this.authentication,
    panoramaxAuthentication: panoramaxAuthentication ?? this.panoramaxAuthentication,
    name: name ?? this.name,
    id: id ?? this.id,
    preferredLanguages: preferredLanguages ?? this.preferredLanguages,
    profileImageUrl: profileImageUrl ?? this.profileImageUrl,
  );
}
