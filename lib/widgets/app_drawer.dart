import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:gitjournal/analytics.dart';
import 'package:gitjournal/state_container.dart';
import 'package:gitjournal/utils.dart';
import 'package:launch_review/launch_review.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget setupGitButton;
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

          getAnalytics().logEvent(
            name: "drawer_setupGitHost",
          );
        },
      );
    }

    var divider = Row(children: <Widget>[Expanded(child: Divider())]);

    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).highlightColor,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage('assets/icon/icon.png'),
                  ),
                ),
              ),
            ),
          ),
          if (setupGitButton != null) ...[setupGitButton, divider],
          ListTile(
            leading: Icon(Icons.note, color: textStyle.color),
            title: Text('Notes', style: textStyle),
            onTap: () {
              var m = ModalRoute.of(context);
              if (m.settings.name == "/") {
                Navigator.pop(context);
              } else {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.folder, color: textStyle.color),
            title: Text('Folders', style: textStyle),
            onTap: () {
              var m = ModalRoute.of(context);
              if (m.settings.name == "/folders") {
                Navigator.pop(context);
              } else {
                Navigator.popAndPushNamed(context, "/folders");
              }
            },
          ),
          divider,
          ListTile(
            leading: Icon(Icons.share, color: textStyle.color),
            title: Text('Share App', style: textStyle),
            onTap: () {
              Navigator.pop(context);
              Share.share('Checkout GitJournal https://gitjournal.io/');

              getAnalytics().logEvent(
                name: "drawer_share",
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.feedback, color: textStyle.color),
            title: Text('Rate Us', style: textStyle),
            onTap: () {
              LaunchReview.launch(
                androidAppId: "io.gitjournal.gitjournal",
                iOSAppId: "1466519634",
              );
              Navigator.pop(context);

              getAnalytics().logEvent(
                name: "drawer_rate",
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.rate_review, color: textStyle.color),
            title: Text('Feedback', style: textStyle),
            onTap: () async {
              var versionText = await getVersionString();

              var platform = Platform.operatingSystem;
              var emailAddress = 'feedback@gitjournal.io';
              var subject = 'GitJournal Feedback';
              var body =
                  "Hey!\n\nHere are some ways to improve GitJournal - \n \n\nVersion: $versionText\nPlatform: $platform";

              subject = Uri.encodeComponent(subject);
              body = Uri.encodeComponent(body);

              var url = 'mailto:$emailAddress?subject=$subject&body=$body';
              launch(url);

              Navigator.pop(context);

              getAnalytics().logEvent(
                name: "drawer_feedback",
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.bug_report, color: textStyle.color),
            title: Text('Bug Report', style: textStyle),
            onTap: () async {
              var platform = Platform.operatingSystem;
              var versionText = await getVersionString();
              var appLogsFilePath = await dumpAppLogs();

              final Email email = Email(
                body:
                    "Hey!\n\nI found a bug in GitJournal - \n \n\nVersion: $versionText\nPlatform: $platform",
                subject: 'GitJournal Bug',
                recipients: ['bugs@gitjournal.io'],
                attachmentPath: appLogsFilePath,
              );

              await FlutterEmailSender.send(email);

              Navigator.pop(context);

              getAnalytics().logEvent(
                name: "drawer_bugreport",
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: textStyle.color),
            title: Text('Settings', style: textStyle),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/settings");

              getAnalytics().logEvent(
                name: "drawer_settings",
              );
            },
          ),
        ],
      ),
    );
  }
}
