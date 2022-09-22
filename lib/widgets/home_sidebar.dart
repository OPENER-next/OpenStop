import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/view_models/osm_authenticated_user_provider.dart';
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
          physics: const ClampingScrollPhysics(),
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
                          onProfileTap: context.watch<OSMAuthenticatedUserProvider>().openUserProfile
                        )
                        : LoginInfoHeader(
                          onLoginTap: context.watch<OSMAuthenticatedUserProvider>().login
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
              leadingIcon: Icons.help,
              title: 'Hilfe',
              onTap: () => Navigator.push(context, Routes.help),
            ),
          ],
        ),
      ),
    );
  }


  void _handleLogout() async {
    final osmAuthenticatedUserProvider = context.read<OSMAuthenticatedUserProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Von OSM abmelden?'),
        content: const Text(
          'Wenn du dich abmeldest, kannst du keine Änderungen mehr zu OpenStreetMap hochladen.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Abmelden'),
          ),
        ],
      )
    );

    if (confirmed == true) {
      osmAuthenticatedUserProvider.logout();
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
    return FloatingActionButton.small(
        heroTag: null,
        onPressed: onTap,
        child: Icon(icon),
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
          FloatingActionButton.extended(
            onPressed: onLoginTap,
            label: const Text('Anmelden'),
            icon: const Icon(Icons.login_rounded)
          ),
        ],
      )
    );
  }
}
