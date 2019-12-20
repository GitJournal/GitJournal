import 'package:flutter/material.dart';
import 'package:gitjournal/apis/git.dart';
import 'package:gitjournal/apis/git_migration.dart';
import 'package:path/path.dart' as p;

const gitFolderName = "journal";
String cloneUrl = "git@github.com:GitJournal/journal_test.git";

class GitApp extends StatefulWidget {
  @override
  _GitAppState createState() => _GitAppState();
}

class _GitAppState extends State<GitApp> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GitRepo gitRepo;

  @override
  void initState() {
    super.initState();

    getGitBaseDirectory().then((dir) async {
      var repoPath = p.join(dir.path, gitFolderName);
      gitRepo = GitRepo(
        folderPath: repoPath,
        authorName: "Vishesh Handa",
        authorEmail: "noemail@example.com",
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Git App',
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Git Test'),
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
    return <Widget>[
      RaisedButton(
          child: const Text("Generate Keys"),
          onPressed: () {
            generateSSHKeys(comment: "Git Sample App");
          }),
      RaisedButton(
        child: const Text("Git Clone"),
        onPressed: () async {
          try {
            await GitRepo.clone(gitRepo.folderPath, cloneUrl);
            _sendSuccess();
          } on GitException catch (ex) {
            print(ex);
            _sendError(ex.toString());
          }
        },
      ),
      RaisedButton(
        child: const Text("Git Pull"),
        onPressed: () async {
          gitRepo.pull();
        },
      ),
      RaisedButton(
        child: const Text("Git Add"),
        onPressed: () async {
          gitRepo.add(".");
        },
      ),
      RaisedButton(
        child: const Text("Git Push"),
        onPressed: () async {
          gitRepo.push();
        },
      ),
      RaisedButton(
        child: const Text("Git Commit"),
        onPressed: () async {
          gitRepo.commit(
            message: "Default message from GitJournal",
            when: "2017-10-20T01:21:10+02:00",
          );
        },
      ),
      RaisedButton(
        child: const Text("Git Reset Last"),
        onPressed: () async {
          gitRepo.resetLast();
        },
      ),
      RaisedButton(
        child: const Text("Git Migrate"),
        onPressed: () async {
          var baseGitPath = await getGitBaseDirectory();
          await migrateGitRepo(
            fromGitBasePath: "journal_local",
            toGitBaseFolder: "journal",
            gitBasePath: baseGitPath.path,
          );
        },
      ),
    ];
  }
}
