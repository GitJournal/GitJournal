import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the Drawer if there isn't enough vertical
      // space to fit everything.
      child: new ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          new UserAccountsDrawerHeader(
            accountEmail: new Text("me@vhanda.in"),
            accountName: new Text("Vishesh Handa"),
            decoration: new BoxDecoration(
              color: Colors.blue,
            ),
          ),
          new ListTile(
            title: new Text('Item 1'),
            onTap: () {
              Navigator.pop(context);

              // Update the state of the app
              // ...
            },
          ),
          new ListTile(
            title: new Text('Item 2'),
            onTap: () {
              Navigator.pop(context);

              // Update the state of the app
              // ...
            },
          ),
        ],
      ),
    );
  }
}
