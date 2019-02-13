import 'package:flutter/material.dart';
import 'package:journal/state_container.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget setupGitButton = Container();
    var appState = StateContainer.of(context).appState;

    if (!appState.remoteGitRepoConfigured) {
      setupGitButton = ListTile(
        title: Text('Setup Git Host'),
        trailing: Icon(
          Icons.priority_high,
          color: Colors.red,
        ),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, "/setupRemoteGit");
        },
      );
    }

    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
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
          ListTile(
            title: Text('Share App'),
            onTap: () {
              Navigator.pop(context);
              // Update the state of the app
              // ...
            },
          ),
          ListTile(
            title: Text('Settings'),
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
