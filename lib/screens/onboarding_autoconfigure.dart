import 'package:flutter/material.dart';

import 'package:journal/apis/github.dart';
import 'package:journal/apis/git.dart';

enum GitRemoteRepo {
  GitHub,
  Gitlab,
  Custom,
}

class OnBoardingAutoConfigure extends StatefulWidget {
  final GitRemoteRepo remoteRepo;
  final Function onDone;

  OnBoardingAutoConfigure({
    @required this.remoteRepo,
    @required this.onDone,
  }) {
    assert(remoteRepo == GitRemoteRepo.GitHub);
  }

  @override
  OnBoardingAutoConfigureState createState() {
    return new OnBoardingAutoConfigureState();
  }
}

class OnBoardingAutoConfigureState extends State<OnBoardingAutoConfigure> {
  var gitHub = new GitHub();

  @override
  void initState() {
    super.initState();

    gitHub.init(() async {
      print("GitHub Initalized");

      var repo = await gitHub.createRepo("journal");
      var publicKey = await generateSSHKeys(comment: "GitJournal");
      await gitHub.addDeployKey(publicKey, repo.fullName);

      widget.onDone(repo.cloneUrl);
    });
    gitHub.launchOAuthScreen();
  }

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[
      Text(
        'Configuring ...',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.display1,
      ),
      SizedBox(height: 8.0),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircularProgressIndicator(
          value: null,
        ),
      ),
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}
