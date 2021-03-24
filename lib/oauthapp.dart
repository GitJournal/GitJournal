import 'package:flutter/material.dart';

import 'apis/githost_factory.dart';

class OAuthApp extends StatefulWidget {
  @override
  OAuthAppState createState() {
    return OAuthAppState();
  }
}

var key =
    'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+VAh8r+vn0c+M+DacOo/szXcdMpxO1kIO3USkzgE5XdO83kQdDwh4Xc4P3dcc+FFSfVcEl3mSXGKbYC3G0ZoVcWd4ed40Gt3sLHSfNRQlRv+obnqKbzDLuOGfq65EkaJ90vrWBo/k7K8tBC2j1FZ/PUYy3DxeQkPEZXCMZDSG5P/+XoHn5IPcaxDpvlZjtOrx4H3pQ/YVI+XmyFAsZe+/Shy5sg4ilsdo4BQN2nODuBLwmgYu/hHmCcd8t4OxgBANVN8TMqHnZfRLixRSuXn0DbV4YOa/b2lBFQNvjkoBF6KhXOxZ+awyjyTpNp4AgF5c+3xptkNwUlwiQDCzcUmH your_email@example.com';

class OAuthAppState extends State<OAuthApp> {
  GitHost githost;

  @override
  void initState() {
    super.initState();

    githost = createGitHost(GitHostType.GitHub);
    githost.init((GitHostException e) {
      if (e != null) {
        print("Got exeception: $e");
      } else {
        print("GitHost initialized and has access code");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OAuth App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('OAuth Test'),
        ),
        body: Column(children: <Widget>[
          ElevatedButton(
            child: const Text("Open OAuth URL"),
            onPressed: () {
              githost.launchOAuthScreen();
            },
          ),
          ElevatedButton(
            child: const Text("List Repos"),
            onPressed: () async {
              try {
                var repos = await githost.listRepos();
                for (var repo in repos) {
                  print(repo);
                }
              } catch (err) {
                print("ListRepos: " + err.toString());
              }
            },
          ),
          ElevatedButton(
            child: const Text("Create Repo"),
            onPressed: () async {
              try {
                var repo = await githost.createRepo("journal_test2");
                print(repo);
              } catch (err) {
                print("Create Repo: " + err.toString());
              }
            },
          ),
          ElevatedButton(
            child: const Text("Add Deploy Key"),
            onPressed: () async {
              try {
                await githost.addDeployKey(key, "vhanda/journal_test2");
              } catch (err) {
                print("Deploy Key: " + err.toString());
              }
            },
          ),
        ]),
      ),
    );
  }
}

void main() async {
  runApp(OAuthApp());
}
