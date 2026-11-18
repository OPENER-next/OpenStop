import 'package:flutter/foundation.dart';
import 'package:osm_api/osm_api.dart';
import 'package:url_launcher/url_launcher.dart';

/// A class holding information about an authenticated user.
///
/// [T] is the type of the user id, which differs between services.

class AuthenticatedUser<T> {
  final Auth authentication;

  final String name;

  final T id;

  /// The server the user is authenticated with.

  final Uri instance;

  final Uri profileUrl;

  final String? profileImageUrl;

  final List<String> preferredLanguages;

  const AuthenticatedUser({
    required this.authentication,
    required this.name,
    required this.id,
    required this.instance,
    required this.profileUrl,
    required this.preferredLanguages,
    this.profileImageUrl,
  });

  Future<bool> openUserProfile() async {
    try {
      return await launchUrl(
        profileUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (error) {
      debugPrint(error.toString());
      return false;
    }
  }
}
