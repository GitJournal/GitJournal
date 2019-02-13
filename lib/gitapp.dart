import 'package:flutter/material.dart';
import 'package:journal/apis/git.dart';
import 'package:journal/apis/git_migration.dart';

const basePath = "journal";
String cloneUrl = "git@github.com:GitJournal/journal_test.git";

class GitApp extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Git App',
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Git Test'),
        ),
        body: Column(
          children: _buildGitButtons(),
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }

  void _sendSuccess() {
    var text = "Success";
    this._scaffoldKey.currentState
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _sendError(String text) {
    this._scaffoldKey.currentState
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text("ERROR: " + text)));
  }

  List<Widget> _buildGitButtons() {
    return <Widget>[
      RaisedButton(
          child: Text("Generate Keys"),
          onPressed: () {
            generateSSHKeys(comment: "Git Sample App");
          }),
      RaisedButton(
        child: Text("Git Clone"),
        onPressed: () async {
          try {
            await gitClone(cloneUrl, basePath);
            _sendSuccess();
          } on GitException catch (ex) {
            print(ex);
            _sendError(ex.toString());
          }
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
}
