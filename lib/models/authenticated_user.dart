import 'package:flutter/foundation.dart';
import 'package:osm_api/osm_api.dart';
import 'package:url_launcher/url_launcher.dart';

/// A class holding information about an authenticated user.

class AuthenticatedUser {
  final Auth authentication;

  final String name;

  final String id;

  final Uri profileUrl;

  final String? profileImageUrl;

  final List<String> preferredLanguages;

  const AuthenticatedUser({
    required this.authentication,
    required this.name,
    required this.id,
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
