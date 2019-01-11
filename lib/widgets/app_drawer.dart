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
          new DrawerHeader(
            decoration: new BoxDecoration(
              color: Theme.of(context).accentColor,
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
        ],
      ),
    );
  }
}
