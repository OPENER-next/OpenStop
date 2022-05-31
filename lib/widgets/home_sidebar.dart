import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '/view_models/osm_authenticated_user_provider.dart';
import '/commons/app_config.dart' as app_config;
import '/commons/osm_config.dart' as osm_config;
import '/commons/routes.dart';
import '/widgets/custom_list_tile.dart';


class HomeSidebar extends StatefulWidget {

  const HomeSidebar({Key? key}) : super(key: key);

  @override
  State<HomeSidebar> createState() => _HomeSidebarState();
}

class _HomeSidebarState extends State<HomeSidebar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: min(MediaQuery.of(context).size.width * 0.65, 300),
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            ColoredBox(
              color: Theme.of(context).colorScheme.primary,
              child: AnimatedSize(
                curve: Curves.easeOutBack,
                duration: const Duration(milliseconds: 300),
                child: Consumer<OSMAuthenticatedUserProvider>(
                  builder: (context, authenticatedUserProvider, child) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: authenticatedUserProvider.isLoggedIn
                        ? UserAccountHeader(
                          name: authenticatedUserProvider.authenticatedUser!.name,
                          imageUrl: authenticatedUserProvider.authenticatedUser?.profileImageUrl,
                          onLogoutTap: _handleLogout,
                          onProfileTap: _handleShowProfile
                        )
                        : LoginInfoHeader(
                          onLoginTap: _handleLogin
                        )
                    );
                  }
                )
              )
            ),
            CustomListTile(
              leadingIcon: Icons.settings,
              title: 'Einstellungen',
              onTap: () => Navigator.push(context, Routes.settings),
            ),
            CustomListTile(
              leadingIcon: Icons.info,
              title: 'Über',
              onTap: () => Navigator.push(context, Routes.about),
            ),
            CustomListTile(
              leadingIcon: Icons.feedback,
              title: 'Feedback',
              trailingIcon: Icons.open_in_new,
              onTap: () => _launchUrl(Uri.parse('${app_config.appProjectUrl}/issues')),
            ),
          ],
        ),
      ),
    );
  }


  void _handleLogin() async {
    final authenticationProvider = context.read<OSMAuthenticatedUserProvider>();
    authenticationProvider.login();
  }


  void _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abmelden'),
        content: const Text(
          'Wenn du dich abmeldest, kannst du keine Änderungen mehr zu OpenStreetMap hochladen.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ZURÜCK'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ABMELDEN'),
          ),
        ],
      )
    );

    if (confirmed == true && mounted) {
      final authenticationProvider = context.read<OSMAuthenticatedUserProvider>();
      authenticationProvider.logout();
    }
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) throw '$url kann nicht aufgerufen werden';
  }

  void _handleShowProfile() {
    final authenticatedUserProvider = context.read<OSMAuthenticatedUserProvider>();
    final userName = authenticatedUserProvider.authenticatedUser?.name;
    if (userName != null) {
      _launchUrl(Uri.parse('${osm_config.osmServerUri}/user/$userName'),);
    }
  }
}


class UserAccountHeader extends StatelessWidget {
  // taken from https://png-pixel.com/
  static final _transparentImage = base64Decode('R0lGODlhAQABAIAAAP///wAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==');

  final String name;
  final String? imageUrl;

  final VoidCallback? onLogoutTap;
  final VoidCallback? onProfileTap;

  final double profilePictureSize;
  final double borderWidth;
  final double borderRadius;
  final Offset buttonOffset;

  const UserAccountHeader({
    required this.name,
    this.imageUrl,
    this.onLogoutTap,
    this.onProfileTap,
    this.profilePictureSize = 100,
    this.borderWidth = 4,
    this.borderRadius = 20,
    this.buttonOffset = const Offset(15, 15),
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalSize = profilePictureSize + 2 * borderWidth;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onProfileTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 15,
            left: 10,
            right: 10,
            bottom: 10
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: buttonOffset.dy + totalSize,
                // double the offset value, because the image is (top) centered
                // therefore the surrounding box needs to be extended equally left and right
                width: 2 * buttonOffset.dx + totalSize,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      // required so the border can be drawn outside/around the image
                      // ignore: use_decorated_box
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onPrimary,
                          borderRadius: BorderRadius.circular(borderRadius + borderWidth),
                          border: Border.all(width: borderWidth, color: theme.colorScheme.onPrimary),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(borderRadius),
                          child: imageUrl == null
                            ? UserAccountImagePlaceholder(
                              size: profilePictureSize,
                            )
                            : FadeInImage.memoryNetwork(
                              placeholder: _transparentImage,
                              image: imageUrl!,
                              fit: BoxFit.cover,
                              width: profilePictureSize,
                              height: profilePictureSize,
                              fadeInDuration: const Duration(milliseconds: 300),
                              imageCacheWidth: profilePictureSize.toInt(),
                              imageCacheHeight: profilePictureSize.toInt(),
                              imageErrorBuilder:(context, error, stackTrace) {
                                return UserAccountImagePlaceholder(
                                  size: profilePictureSize,
                                );
                              },
                          )
                        )
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: UserAccountActionButton(
                        onTap: onLogoutTap,
                        icon: Icons.logout_rounded,
                      ),
                    )
                  ],
                )
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary
                  ),
                )
              ),
            ],
          )
        )
      )
    );
  }
}


class UserAccountActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const UserAccountActionButton({
    required this.icon,
    this.onTap,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                spreadRadius: 3,
                blurRadius: 4,
                color: Theme.of(context).colorScheme.shadow
              )
            ]
          ),
      child: FloatingActionButton.small(
        heroTag: null,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        onPressed: onTap,
        elevation: 0,
        child: Icon(icon),
      ),
    );
  }
}


class UserAccountImagePlaceholder extends StatelessWidget {
  final double size;

  const UserAccountImagePlaceholder({
    required this.size,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Icon(
        Icons.person,
        size: size/2,
        color: Theme.of(context).iconTheme.color?.withOpacity(0.25),
      ),
    );
  }
}


class LoginInfoHeader extends StatelessWidget {
  final VoidCallback? onLoginTap;

  const LoginInfoHeader({
    this.onLoginTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 25,
        left: 15,
        right: 15,
        bottom: 25
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Melde dich mit deinem OpenStreetMap-Konto an, um deine Änderungen hochzuladen.',
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onPrimary
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(theme.colorScheme.onPrimary),
              textStyle: MaterialStateProperty.all<TextStyle>(
                const TextStyle(fontSize: 14)
              ),
            ),
            onPressed: onLoginTap,
            child: Text(
              'ANMELDEN',
              style: TextStyle(
                color: theme.textTheme.bodyText1?.color
              ),
            )
          ),
        ],
      )
    );
  }
}
