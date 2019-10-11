import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:function_types/function_types.dart';

import 'package:gitjournal/analytics.dart';
import 'package:gitjournal/apis/git.dart';
import 'package:gitjournal/apis/githost_factory.dart';
import 'package:gitjournal/settings.dart';

import 'githostsetup_button.dart';
import 'githostsetup_error.dart';
import 'githostsetup_loading.dart';

class GitHostSetupAutoConfigure extends StatefulWidget {
  final GitHostType gitHostType;
  final Func1<String, void> onDone;

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

  @override
  void initState() {
    super.initState();
  }

  void _startAutoConfigure() async {
    Fimber.d("Starting autoconfigure");
    setState(() {
      _configuringStarted = true;
    });

    gitHost = createGitHost(widget.gitHostType);
    try {
      gitHost.init((Exception error) async {
        if (error != null) {
          throw error;
        }
        Fimber.d("GitHost Initalized: " + widget.gitHostType.toString());

        GitHostRepo repo;
        try {
          setState(() {
            _message = "Creating private repo";
          });

          try {
            repo = await gitHost.createRepo("journal");
          } on GitHostException catch (e) {
            if (e.cause != GitHostException.RepoExists.cause) {
              rethrow;
            }

            setState(() {
              _message = "Using existing repo";
            });
            repo = await gitHost.getRepo("journal");
          }

          setState(() {
            _message = "Generating SSH Key";
          });
          var publicKey = await generateSSHKeys(comment: "GitJournal");

          setState(() {
            _message = "Adding as a Deploy Key";
          });
          await gitHost.addDeployKey(publicKey, repo.fullName);

          var userInfo = await gitHost.getUserInfo();
          if (userInfo.name != null && userInfo.name.isNotEmpty) {
            Settings.instance.gitAuthor = userInfo.name;
          }
          if (userInfo.email != null && userInfo.email.isNotEmpty) {
            Settings.instance.gitAuthorEmail = userInfo.email;
          }
          Settings.instance.save();
        } on GitHostException catch (e) {
          _handleGitHostException(e);
          return;
        }
        widget.onDone(repo.cloneUrl);
      });

      try {
        await gitHost.launchOAuthScreen();
      } on PlatformException catch (e, stack) {
        print("LaunchOAuthScreen: Caught platform exception: " + e.toString());
        print(stack);
        print("Ignoring it, since I don't know what else to do");
      }
    } on GitHostException catch (e) {
      _handleGitHostException(e);
    }
  }

  void _handleGitHostException(GitHostException e) {
    Fimber.d("GitHostSetupAutoConfigure: " + e.toString());
    setState(() {
      errorMessage = widget.gitHostType.toString() + ": " + e.toString();
      getAnalytics().logEvent(
        name: "githostsetup_error",
        parameters: <String, dynamic>{
          'errorMessage': errorMessage,
        },
      );
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
          style: Theme.of(context).textTheme.title,
        ),
        SizedBox(height: 32.0),

        // Step 1
        Text(
          "1. Create a new private repo called 'journal' or use the existing one",
          style: Theme.of(context).textTheme.body2,
        ),
        SizedBox(height: 8.0),
        Text(
          "2. Generate an SSH Key on this device",
          style: Theme.of(context).textTheme.body2,
        ),
        SizedBox(height: 8.0),
        Text(
          "3. Add the key as a deploy key with write access to the created repo",
          style: Theme.of(context).textTheme.body2,
        ),
        SizedBox(height: 32.0),

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
