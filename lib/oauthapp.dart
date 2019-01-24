import 'package:flutter/material.dart';

import 'package:journal/apis/github.dart';
import 'package:journal/apis/gitlab.dart';

class OAuthApp extends StatefulWidget {
  @override
  OAuthAppState createState() {
    return new OAuthAppState();
  }
}

var key =
    'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+VAh8r+vn0c+M+DacOo/szXcdMpxO1kIO3USkzgE5XdO83kQdDwh4Xc4P3dcc+FFSfVcEl3mSXGKbYC3G0ZoVcWd4ed40Gt3sLHSfNRQlRv+obnqKbzDLuOGfq65EkaJ90vrWBo/k7K8tBC2j1FZ/PUYy3DxeQkPEZXCMZDSG5P/+XoHn5IPcaxDpvlZjtOrx4H3pQ/YVI+XmyFAsZe+/Shy5sg4ilsdo4BQN2nODuBLwmgYu/hHmCcd8t4OxgBANVN8TMqHnZfRLixRSuXn0DbV4YOa/b2lBFQNvjkoBF6KhXOxZ+awyjyTpNp4AgF5c+3xptkNwUlwiQDCzcUmH your_email@example.com';

class OAuthAppState extends State<OAuthApp> {
  var github = new Gitlab();

  void initState() {
    super.initState();
    github.init(() {
      print("GitHub initialized and has access code");
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'OAuth App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('OAuth Test'),
        ),
        body: Column(children: <Widget>[
          RaisedButton(
            child: Text("Open OAuth URL"),
            onPressed: () {
              github.launchOAuthScreen();
            },
          ),
          RaisedButton(
            child: Text("List Repos"),
            onPressed: () async {
              try {
                var repos = await github.listRepos();
                for (var repo in repos) {
                  print(repo);
                }
              } catch (err) {
                print("ListRepos: " + err.toString());
              }
            },
          ),
          RaisedButton(
            child: Text("Create Repo"),
            onPressed: () async {
              try {
                var repo = await github.createRepo("journal_test2");
                print(repo);
              } catch (err) {
                print("Create Repo: " + err.toString());
              }
            },
          ),
          RaisedButton(
            child: Text("Add Deploy Key"),
            onPressed: () async {
              try {
                await github.addDeployKey(key, "vhanda/journal_test2");
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
