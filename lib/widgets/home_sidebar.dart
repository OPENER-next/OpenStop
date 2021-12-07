import 'package:flutter/material.dart';

/// Builds the drawer/sidebar providing access to additional settings.

class HomeSidebar extends StatefulWidget {

  const HomeSidebar({Key? key}) : super(key: key);

  @override
  _HomeSidebarState createState() => _HomeSidebarState();
}


class _HomeSidebarState extends State<HomeSidebar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.65,
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
                color: Colors.black54
              ),
              title: const Text('Einstellungen'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(
                Icons.info,
                color: Colors.black54
              ),
              title: const Text('Über'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.feedback,
                color: Colors.black54
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
