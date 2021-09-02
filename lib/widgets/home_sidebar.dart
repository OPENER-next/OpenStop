import 'package:flutter/material.dart';

/// Builds the drawer/sidebar providing access to additional settings.

class HomeSidebar extends StatefulWidget {
  @override
  _HomeSidebarState createState() => _HomeSidebarState();
}


class _HomeSidebarState extends State<HomeSidebar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.65,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundColor: Theme.of(context).accentColor,
                child:
                  Text('MM',
                    style: Theme.of(context).textTheme.headline5,
                  ),
              ),
              accountName: Text("Max Muster"),
              accountEmail: null,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              onDetailsPressed: () {},
            ),
            ListTile(
              leading: Icon(
                Icons.settings,
                color: Colors.black54
              ),
              title: Text('Einstellungen'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(
                Icons.info,
                color: Colors.black54
              ),
              title: Text('Über'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.feedback,
                color: Colors.black54
              ),
              title: Text('Feedback'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}