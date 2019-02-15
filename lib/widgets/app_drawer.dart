import 'package:flutter/material.dart';
import 'package:journal/state_container.dart';
import 'package:launch_review/launch_review.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget setupGitButton = Container();
    var appState = StateContainer.of(context).appState;

    var textStyle = Theme.of(context).textTheme.body2;

    if (!appState.remoteGitRepoConfigured) {
      setupGitButton = ListTile(
        leading: Icon(Icons.sync, color: textStyle.color),
        title: Text('Setup Git Host', style: textStyle),
        trailing: Icon(
          Icons.info,
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
            leading: Icon(Icons.share, color: textStyle.color),
            title: Text('Share App', style: textStyle),
            onTap: () {
              Navigator.pop(context);
              Share.share('Checkout GitJournal https://gitjournal.io/');
            },
          ),
          ListTile(
            leading: Icon(Icons.feedback, color: textStyle.color),
            title: Text('Rate Us', style: textStyle),
            onTap: () {
              LaunchReview.launch();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.rate_review, color: textStyle.color),
            title: Text('Feedback', style: textStyle),
            onTap: () {
              var emailAddress = 'gitjournal.io@gmail.com';
              var subject = 'GitJournal Feedback';
              var body =
                  "Hey!\n\nHere are some ways to improve GitJournal - \n";
              var url = 'mailto:$emailAddress?subject=$subject&body=$body';
              launch(url);

              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: textStyle.color),
            title: Text('Settings', style: textStyle),
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
