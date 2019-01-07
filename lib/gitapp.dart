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
      onPressed: generateSSHKeys,
    ),
    RaisedButton(
      child: Text("Git Clone"),
      onPressed: gitClone,
    ),
    RaisedButton(
      child: Text("Git Pull"),
      onPressed: gitPull,
    ),
    RaisedButton(
      child: Text("Git Add"),
      onPressed: gitAdd,
    ),
    RaisedButton(
      child: Text("Git Push"),
      onPressed: gitPush,
    ),
    RaisedButton(
      child: Text("Git Commit"),
      onPressed: gitCommit,
    ),
  ];
}
