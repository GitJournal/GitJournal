import 'package:flutter/material.dart';
import 'package:journal/storage/git.dart';

class GitApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Git App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Git Test'),
        ),
        body: Column(
          children: buildGitButtons(),
        ),
      ),
    );
  }
}

buildGitButtons() {
  return <Widget>[
    RaisedButton(
        child: Text("Generate Keys"),
        onPressed: () {
          generateSSHKeys(comment: "Git Sample App");
        }),
    RaisedButton(
      child: Text("Git Clone"),
      onPressed: () async {
        gitClone("root@bcn.vhanda.in:git/test", "journal");
      },
    ),
    RaisedButton(
      child: Text("Git Pull"),
      onPressed: () async {
        gitPull("journal");
      },
    ),
    RaisedButton(
      child: Text("Git Add"),
      onPressed: () async {
        await gitAdd("journal", "1");
      },
    ),
    RaisedButton(
      child: Text("Git Push"),
      onPressed: () async {
        gitPush("journal");
      },
    ),
    RaisedButton(
        child: Text("Git Commit"),
        onPressed: () async {
          gitCommit(
            gitFolder: "journal",
            authorEmail: "noemail@example.com",
            authorName: "Vishesh Handa",
            message: "Default message from GitJournal",
          );
        }),
  ];
}
