import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as url;

import '/view_models/osm_authentication_provider.dart';
import '/commons/osm_config.dart' as osm_config;
import '/commons/screens.dart';


class HomeSidebar extends StatefulWidget {

  const HomeSidebar({Key? key}) : super(key: key);

  @override
  _HomeSidebarState createState() => _HomeSidebarState();
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
            ColoredBox(color: Theme.of(context).colorScheme.primary,
              child: AnimatedSize(
                curve: Curves.easeOutBack,
                duration: const Duration(milliseconds: 300),
                child: Consumer<OSMAuthenticationProvider>(
                  builder: (context, authenticationProvider, child) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: authenticationProvider.isLoggedIn
                        ? UserAccountHeader(
                          name: authenticationProvider.userDetails?.name ?? 'Unknown',
                          imageUrl: authenticationProvider.userDetails?.profileImageUrl,
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
            ListTile(
              leading: const Icon(
                Icons.settings,
              ),
              title: const Text('Einstellungen'),
              onTap: () => Navigator.pushNamed(context, Screen.settings),
            ),
            ListTile(
              leading: const Icon(
                Icons.info,
              ),
              title: const Text('Über'),
              onTap: () => Navigator.pushNamed(context, Screen.about),
            ),
            ListTile(
              leading: const Icon(Icons.feedback,
              ),
              title: const Text('Feedback'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }


  void _handleLogin() async {
    final authenticationProvider = context.read<OSMAuthenticationProvider>();
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

    if (confirmed == true) {
      final authenticationProvider = context.read<OSMAuthenticationProvider>();
      authenticationProvider.logout();
    }
  }


  void _handleShowProfile() {
    final authenticationProvider = context.read<OSMAuthenticationProvider>();
    final userName = authenticationProvider.userDetails?.name;
    if (userName != null) {
      url.launch('${osm_config.osmServerUri}/user/$userName');
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
