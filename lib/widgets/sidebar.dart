import 'package:flutter/material.dart';

/**
 * Builds the drawer/sidebar providing access to additional settings.
 */
class Sidebar extends StatefulWidget {
  @override
  _SidebarState createState() => _SidebarState();
}


class _SidebarState extends State<Sidebar> {
  @override
  Widget build(BuildContext context) {
    return Drawer(child:
      ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: const Text('UN'),
            ),
            accountName: Text("User Name"),
            accountEmail: null,
            decoration: BoxDecoration(
              color: Colors.orange,
            ),
            onDetailsPressed: () {},
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Options'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Item 2'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('Item 2'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}