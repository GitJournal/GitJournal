import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      child: Text("Remove Directory"),
      onPressed: () {
        print("FOO");
      },
    ),
    RaisedButton(
      child: Text("Git Clone"),
      onPressed: () async {
        await gitClone();
      },
    ),
    RaisedButton(
      child: Text("New File"),
      onPressed: () {
        print("FOO");
      },
    ),
  ];
}

Future gitClone() async {
  const platform = const MethodChannel('samples.flutter.io/battery');

  print("Going to git clone");
  await platform.invokeMethod('gitClone', {
    'cloneUrl': "root@bcn.vhanda.in:git/notes",
    'filePath': "/",
  });
  print("FOO");
}
