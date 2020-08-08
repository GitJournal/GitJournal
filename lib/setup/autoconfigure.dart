import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:function_types/function_types.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/analytics.dart';
import 'package:gitjournal/apis/githost_factory.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/utils/logger.dart';
import 'button.dart';
import 'error.dart';
import 'loading.dart';

class GitHostSetupAutoConfigure extends StatefulWidget {
  final GitHostType gitHostType;
  final Func1<GitHost, void> onDone;

  GitHostSetupAutoConfigure({
    @required this.gitHostType,
    @required this.onDone,
  });

  @override
  GitHostSetupAutoConfigureState createState() {
    return GitHostSetupAutoConfigureState();
  }
}

class GitHostSetupAutoConfigureState extends State<GitHostSetupAutoConfigure> {
  GitHost gitHost;
  String errorMessage = "";

  bool _configuringStarted = false;
  String _message = "Waiting for Permissions ...";

  void _startAutoConfigure() async {
    Log.d("Starting autoconfigure");
    setState(() {
      _configuringStarted = true;
    });

    gitHost = createGitHost(widget.gitHostType);
    try {
      gitHost.init((Exception error) async {
        if (error != null) {
          throw error;
        }
        Log.d("GitHost Initalized: " + widget.gitHostType.toString());

        try {
          setState(() {
            _message = "Reading User Info";
          });

          var userInfo = await gitHost.getUserInfo();
          var settings = Provider.of<Settings>(context, listen: false);
          if (userInfo.name != null && userInfo.name.isNotEmpty) {
            settings.gitAuthor = userInfo.name;
          }
          if (userInfo.email != null && userInfo.email.isNotEmpty) {
            settings.gitAuthorEmail = userInfo.email;
          }
          settings.save();
        } on Exception catch (e, stacktrace) {
          _handleGitHostException(e, stacktrace);
          return;
        }
        widget.onDone(gitHost);
      });

      try {
        await gitHost.launchOAuthScreen();
      } on PlatformException catch (e, stack) {
        Log.d("LaunchOAuthScreen: Caught platform exception:",
            ex: e, stacktrace: stack);
        Log.d("Ignoring it, since I don't know what else to do");
      }
    } on Exception catch (e, stacktrace) {
      _handleGitHostException(e, stacktrace);
    }
  }

  void _handleGitHostException(Exception e, StackTrace stacktrace) {
    Log.d("GitHostSetupAutoConfigure: " + e.toString());
    setState(() {
      errorMessage = widget.gitHostType.toString() + ": " + e.toString();
      getAnalytics().logEvent(
        name: "githostsetup_error",
        parameters: <String, String>{
          'errorMessage': errorMessage,
        },
      );

      logException(e, stacktrace);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_configuringStarted) {
      if (errorMessage == null || errorMessage.isEmpty) {
        return GitHostSetupLoadingPage(_message);
      }

      return GitHostSetupErrorPage(errorMessage);
    }

    var columns = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'We need permission to perform the following steps:',
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(height: 32.0),

        // Step 1
        Text(
          "1. List your existing repos or create a new repo",
          style: Theme.of(context).textTheme.bodyText1,
        ),
        const SizedBox(height: 8.0),
        Text(
          "2. Generate an SSH Key on this device",
          style: Theme.of(context).textTheme.bodyText1,
        ),
        const SizedBox(height: 8.0),
        Text(
          "3. Add the key as a deploy key with write access to the created repo",
          style: Theme.of(context).textTheme.bodyText1,
        ),
        const SizedBox(height: 32.0),

        GitHostSetupButton(
          text: "Authorize GitJournal",
          onPressed: _startAutoConfigure,
        ),
      ],
    );

    return Center(
      child: SingleChildScrollView(
        child: columns,
      ),
    );
  }
}
