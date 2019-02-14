import 'package:flutter/material.dart';
import 'package:journal/apis/git.dart';
import 'package:journal/apis/githost_factory.dart';
import 'package:journal/settings.dart';

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

  @override
  void initState() {
    super.initState();

    print("Starting autoconfigure");
    gitHost = createGitHost(widget.gitHostType);
    try {
      gitHost.init((Exception error) async {
        if (error != null) {
          throw error;
        }
        print("GitHost Initalized: " + widget.gitHostType.toString());

        GitRepo repo;
        try {
          // FIXME: What if repo already exists?
          repo = await gitHost.createRepo("journal");

          var publicKey = await generateSSHKeys(comment: "GitJournal");
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
    if (this.errorMessage == null || this.errorMessage.isEmpty) {
      return GitHostSetupLoadingPage("Configuring ...");
    }

    return GitHostSetupErrorPage(errorMessage);
  }
}
