import 'package:flutter/material.dart';
import 'package:journal/apis/git.dart';
import 'package:journal/apis/githost_factory.dart';
import 'package:journal/settings.dart';

import 'githostsetup_button.dart';
import 'githostsetup_error.dart';
import 'githostsetup_loading.dart';

class GitHostSetupAutoConfigure extends StatefulWidget {
  final GitHostType gitHostType;
  final Function onDone;

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

  void _startAutoConfigure() {
    print("Starting autoconfigure");
    setState(() {
      _configuringStarted = true;
    });

    gitHost = createGitHost(widget.gitHostType);
    try {
      gitHost.init((Exception error) async {
        if (error != null) {
          throw error;
        }
        print("GitHost Initalized: " + widget.gitHostType.toString());

        GitRepo repo;
        try {
          this.setState(() {
            _message = "Creating private repo";
          });

          try {
            repo = await gitHost.createRepo("journal");
          } on GitHostException catch (e) {
            if (e.cause != GitHostException.RepoExists.cause) {
              rethrow;
            }

            this.setState(() {
              _message = "Using existing repo";
            });
            repo = await gitHost.getRepo("journal");
          }

          this.setState(() {
            _message = "Generating SSH Key";
          });
          var publicKey = await generateSSHKeys(comment: "GitJournal");

          this.setState(() {
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
          print("GitHostSetupAutoConfigure: " + e.toString());
          setState(() {
            errorMessage = widget.gitHostType.toString() + ": " + e.toString();
          });
        }
        widget.onDone(repo.cloneUrl);
      });
      gitHost.launchOAuthScreen();
    } on GitHostException catch (e) {
      print("GitHostSetupAutoConfigure: " + e.toString());
      setState(() {
        errorMessage = widget.gitHostType.toString() + ": " + e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_configuringStarted) {
      if (this.errorMessage == null || this.errorMessage.isEmpty) {
        return GitHostSetupLoadingPage(_message);
      }

      return GitHostSetupErrorPage(errorMessage);
    }

    var columns = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'We need to perform the following steps:',
          style: Theme.of(context).textTheme.title,
        ),
        SizedBox(height: 32.0),

        // Step 1
        Text(
          "1. Create a new private repo called 'journal'",
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
