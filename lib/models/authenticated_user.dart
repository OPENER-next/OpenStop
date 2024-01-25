// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:osm_api/osm_api.dart';

/// A class holding information about an authenticated OpenStreetMap user.

class AuthenticatedUser {
  final Auth authentication;

  final String name;

  final int id;

  final String? profileImageUrl;

  final List<String> preferredLanguages;

  const AuthenticatedUser({
    required this.authentication,
    required this.name,
    required this.id,
    required this.preferredLanguages,
    this.profileImageUrl
  });
}
