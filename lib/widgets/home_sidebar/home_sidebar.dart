import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mvvm_architecture/base.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/view_models/home_view_model.dart';
import '/commons/routes.dart';
import '/widgets/custom_list_tile.dart';
import 'login_info_header.dart';
import 'user_account_header.dart';


class HomeSidebar extends ViewFragment<HomeViewModel> {
  const HomeSidebar({super.key});
  
  @override
  Widget build(BuildContext context, viewModel) {
    final appLocale = AppLocalizations.of(context)!;
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
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: viewModel.userIsLoggedIn
                  ? UserAccountHeader(
                    name: viewModel.userName!,
                    imageUrl: viewModel.userProfileImageUrl,
                    onLogoutTap: viewModel.logout,
                    onProfileTap: viewModel.openUserProfile,
                  )
                  : LoginInfoHeader(
                    onLoginTap: viewModel.login,
                  ),
              ),
            ),
          ),
          CustomListTile(
            leadingIcon: Icons.settings,
            title: appLocale.settingsTitle,
            onTap: () => Navigator.push(context, Routes.settings),
          ),
          CustomListTile(
            leadingIcon: Icons.info,
            title: appLocale.aboutTitle,
            onTap: () => Navigator.push(context, Routes.about),
          ),
          CustomListTile(
            leadingIcon: Icons.help,
            title: appLocale.helpTitle,
            onTap: () => Navigator.push(context, Routes.help),
          ),
          Visibility(
            visible: false,
            maintainState: true,
            maintainSemantics: true,
            maintainSize: true,
            maintainAnimation: true,
            maintainInteractivity: true,
            child: CustomListTile(
              leadingIcon: Icons.arrow_back,
              title: appLocale.semanticsCloseNavigationMenuButton,
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
