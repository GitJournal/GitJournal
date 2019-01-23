import 'package:flutter/material.dart';
import 'package:journal/storage/git.dart';

import 'package:journal/apis/git_migration.dart';

const basePath = "journal";

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
        gitClone("root@bcn.vhanda.in:git/test", basePath);
      },
    ),
    RaisedButton(
      child: Text("Git Pull"),
      onPressed: () async {
        gitPull(basePath);
      },
    ),
    RaisedButton(
      child: Text("Git Add"),
      onPressed: () async {
        await gitAdd(basePath, ".");
      },
    ),
    RaisedButton(
      child: Text("Git Push"),
      onPressed: () async {
        gitPush(basePath);
      },
    ),
    RaisedButton(
      child: Text("Git Commit"),
      onPressed: () async {
        gitCommit(
          gitFolder: basePath,
          authorEmail: "noemail@example.com",
          authorName: "Vishesh Handa",
          message: "Default message from GitJournal",
          when: "2017-10-20T01:21:10+02:00",
        );
      },
    ),
    RaisedButton(
      child: Text("Git Migrate"),
      onPressed: () async {
        var baseGitPath = await getGitBaseDirectory();
        await migrateGitRepo(
          fromGitBasePath: "journal_local",
          toGitBasePath: "journal",
          gitBasePath: baseGitPath.path,
        );
      },
    ),
  ];
}
