import 'package:flutter/material.dart';
import 'package:journal/state_container.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget setupGitButton = new Container();
    var appState = StateContainer.of(context).appState;

    if (!appState.remoteGitRepoConfigured) {
      setupGitButton = ListTile(
        title: new Text('Setup Git Sync'),
        onTap: () {
          Navigator.pop(context);
          // Update the state of the app
          // ...
        },
      );
    }

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
          setupGitButton,
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
