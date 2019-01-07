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
      child: Text("Generate Keys"),
      onPressed: () async {
        await generateSSHKeys();
      },
    ),
    RaisedButton(
      child: Text("Git Clone"),
      onPressed: () async {
        await gitClone();
      },
    ),
    RaisedButton(
      child: Text("Git Pull"),
      onPressed: () async {
        await gitPull();
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
  const platform = const MethodChannel('gitjournal.io/git');

  print("Going to git clone");
  try {
    await platform.invokeMethod('gitClone', {
      'cloneUrl': "root@bcn.vhanda.in:git/test",
      'folderName': "journal",
    });
    print("Done");
  } on PlatformException catch (e) {
    print("gitClone Failed: '${e.message}'.");
  }
}

Future generateSSHKeys() async {
  print("generateSSHKeyss");
  try {
    const platform = const MethodChannel('gitjournal.io/git');
    String publicKey = await platform.invokeMethod('generateSSHKeys', {});
    print("Public Key " + publicKey);
  } on PlatformException catch (e) {
    print("Failed to generateSSHKeys: '${e.message}'.");
  }
}

Future gitPull() async {
  const platform = const MethodChannel('gitjournal.io/git');

  print("Going to git pull");
  try {
    await platform.invokeMethod('gitPull', {
      'folderName': "journal",
    });
    print("Done");
  } on PlatformException catch (e) {
    print("gitPull Failed: '${e.message}'.");
  }
}
