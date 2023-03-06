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
    return Drawer(
      width: min(MediaQuery.of(context).size.width * 0.65, 300),
      backgroundColor: Theme.of(context).colorScheme.background,
      shape: const Border(),
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
    this.borderRadius = 12,
    this.buttonOffset = const Offset(10, 10),
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final link = LayerLink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 15 + borderWidth,
        left: 10,
        right: 10,
        bottom: 15
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              CompositedTransformTarget(
                link: link,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(
                      width: borderWidth,
                      color: theme.colorScheme.primaryContainer,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
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
                      imageCacheHeight: profilePictureSize.toInt(),
                      imageErrorBuilder:(context, error, stackTrace) {
                        return UserAccountImagePlaceholder(
                          size: profilePictureSize,
                        );
                      },
                    ),
                ),
              ),
              Positioned.fill(
                child: Material(
                  type: MaterialType.transparency,
                  borderRadius: BorderRadius.circular(borderRadius),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onProfileTap,
                  ),
                ),
              ),
              CompositedTransformFollower(
                link: link,
                targetAnchor: Alignment.bottomRight,
                followerAnchor: Alignment.center,
                child: UserAccountActionButton(
                  onTap: onLogoutTap,
                  icon: Icons.logout_rounded,
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 25, bottom: 10),
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
    );
  }
}


class UserAccountActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;

  const UserAccountActionButton({
    required this.icon,
    this.onTap,
    this.tooltip,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: IconButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        side: BorderSide(
          width: 4,
          strokeAlign: BorderSide.strokeAlignOutside,
          color: Theme.of(context).colorScheme.primary
        ),
      ),
      tooltip: tooltip,
      icon: Icon(icon),
      onPressed: onTap,
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
        color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.4),
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
        crossAxisAlignment: CrossAxisAlignment.center,
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
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            onPressed: onLoginTap,
            label: const Text('Anmelden'),
            icon: const Icon(Icons.login_rounded)
          ),
        ],
      )
    );
  }
}
