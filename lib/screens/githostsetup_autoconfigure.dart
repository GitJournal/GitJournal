import 'package:flutter/material.dart';
import 'package:journal/apis/git.dart';
import 'package:journal/apis/githost_factory.dart';
import 'package:journal/settings.dart';

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
      gitHost.init(() async {
        print("GitHost Initalized: " + widget.gitHostType.toString());

        GitRepo repo;
        try {
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
    var children = <Widget>[];
    if (this.errorMessage == null || this.errorMessage.isEmpty) {
      children = <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Configuring ...',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.display1,
          ),
        ),
        SizedBox(height: 8.0),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircularProgressIndicator(
            value: null,
          ),
        ),
      ];
    } else {
      children = <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Failed',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.display1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            this.errorMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.display1,
          ),
        ),
      ];
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}
