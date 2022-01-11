import 'dart:math';

import 'package:flutter/material.dart';

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
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child:
                  Text('MM',
                    style: Theme.of(context).textTheme.headline5,
                  ),
              ),
              accountName: const Text('Max Muster'),
              accountEmail: null,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              onDetailsPressed: () {},
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
}
