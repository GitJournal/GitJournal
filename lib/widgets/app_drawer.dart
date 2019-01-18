import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child: new ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          new DrawerHeader(
            decoration: new BoxDecoration(
              color: Theme.of(context).buttonColor,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/icon/icon.png'),
                  ),
                ),
              ),
            ),
          ),
          new ListTile(
            title: new Text('Share App'),
            onTap: () {
              Navigator.pop(context);
              // Update the state of the app
              // ...
            },
          ),
          new ListTile(
            title: new Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/settings");
            },
          ),
        ],
      ),
    );
  }
}
