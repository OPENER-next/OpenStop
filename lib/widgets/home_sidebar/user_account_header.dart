import 'dart:convert';

import 'package:flutter/material.dart';


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
    super.key,
  });

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
      // The outer Stack is necessary, because when using the inner Stack for the
      // CompositedTransformFollower it will only be clickable in the bounds of
      // the inner Stack. Also the expanding container (width: double.infinity)
      // is required for this.
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CompositedTransformTarget(
                link: link,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
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
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 25, bottom: 10),
                child: Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
          CompositedTransformFollower(
            link: link,
            targetAnchor: Alignment.bottomRight,
            followerAnchor: Alignment.center,
            child: UserAccountActionButton(
              onTap: onLogoutTap,
              icon: Icons.logout_rounded,
            ),
          ),
        ],
      ),
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
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: IconButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        side: BorderSide(
          width: 4,
          strokeAlign: BorderSide.strokeAlignOutside,
          color: Theme.of(context).colorScheme.primary,
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
    super.key,
  });

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
