import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mvvm_architecture/base.dart';

import '/view_models/home_view_model.dart';
import '/commons/routes.dart';
import '/widgets/custom_list_tile.dart';
import 'login_info_header.dart';
import 'user_account_header.dart';


class HomeSidebar extends ViewFragment<HomeViewModel> {
  const HomeSidebar({super.key});

  @override
  Widget build(BuildContext context, viewModel) {
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
}
