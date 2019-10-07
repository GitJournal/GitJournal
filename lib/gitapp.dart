import 'package:flutter/material.dart';
import 'package:gitjournal/apis/git.dart';
import 'package:gitjournal/apis/git_migration.dart';

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
    _scaffoldKey.currentState
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _sendError(String text) {
    _scaffoldKey.currentState
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text("ERROR: " + text)));
  }

  List<Widget> _buildGitButtons() {
    var gitRepo = GitRepo(
      folderName: basePath,
      authorName: "Vishesh Handa",
      authorEmail: "noemail@example.com",
    );

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
            await GitRepo.clone(basePath, cloneUrl);
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
          gitRepo.pull();
        },
      ),
      RaisedButton(
        child: Text("Git Add"),
        onPressed: () async {
          gitRepo.add(".");
        },
      ),
      RaisedButton(
        child: Text("Git Push"),
        onPressed: () async {
          gitRepo.push();
        },
      ),
      RaisedButton(
        child: Text("Git Commit"),
        onPressed: () async {
          gitRepo.commit(
            message: "Default message from GitJournal",
            when: "2017-10-20T01:21:10+02:00",
          );
        },
      ),
      RaisedButton(
        child: Text("Git Reset Last"),
        onPressed: () async {
          gitRepo.resetLast();
        },
      ),
      RaisedButton(
        child: Text("Git Migrate"),
        onPressed: () async {
          var baseGitPath = await getGitBaseDirectory();
          await migrateGitRepo(
            fromGitBasePath: "journal_local",
            toGitBaseFolder: "journal",
            toGitBaseSubFolder: "",
            gitBasePath: baseGitPath.path,
          );
        },
      ),
    ];
  }
}
