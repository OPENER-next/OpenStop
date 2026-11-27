import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mvvm_architecture/base.dart';

import '/commons/routes.dart';
import '/l10n/app_localizations.g.dart';
import '/view_models/home_view_model.dart';
import 'login_info_header.dart';
import 'user_account_header.dart';

class HomeSidebar extends ViewFragment<HomeViewModel> {
  const HomeSidebar({super.key});

  @override
  Widget build(BuildContext context, viewModel) {
    final appLocale = AppLocalizations.of(context)!;
    return Drawer(
      width: min(MediaQuery.of(context).size.width * 0.65, 300),
      backgroundColor: Theme.of(context).colorScheme.surface,
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
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(appLocale.settingsTitle),
            onTap: () => Navigator.push(context, Routes.settings),
          ),
          ListTile(
            leading: const Icon(MdiIcons.shapePlus),
            title: Text(appLocale.servicesTitle),
            onTap: () => Navigator.push(context, Routes.services),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(appLocale.aboutTitle),
            onTap: () => Navigator.push(context, Routes.about),
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: Text(appLocale.helpTitle),
            onTap: () => Navigator.push(context, Routes.help),
          ),
        ],
      ),
    );
  }
}
