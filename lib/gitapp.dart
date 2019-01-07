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

Future gitAdd() async {
  const platform = const MethodChannel('gitjournal.io/git');

  print("Going to git add");
  try {
    await platform.invokeMethod('gitAdd', {
      'folderName': "journal",
      'filePattern': ".",
    });
    print("Done");
  } on PlatformException catch (e) {
    print("gitAdd Failed: '${e.message}'.");
  }
}

Future gitPush() async {
  const platform = const MethodChannel('gitjournal.io/git');

  print("Going to git push");
  try {
    await platform.invokeMethod('gitPush', {
      'folderName': "journal",
    });
    print("Done");
  } on PlatformException catch (e) {
    print("gitPush Failed: '${e.message}'.");
  }
}

Future gitCommit() async {
  const platform = const MethodChannel('gitjournal.io/git');

  print("Going to git commit");
  try {
    await platform.invokeMethod('gitCommit', {
      'folderName': "journal",
      'authorName': "Vishesh Handa",
      'authorEmail': "noemail@example.com",
      'message': "Default message from GitJournal",
    });
    print("Done");
  } on PlatformException catch (e) {
    print("gitCommit Failed: '${e.message}'.");
  }
}
