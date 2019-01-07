import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

const _platform = const MethodChannel('gitjournal.io/git');

Future<Directory> getGitBaseDirectory() async {
  final String path = await _platform.invokeMethod('getBaseDirectory');
  if (path == null) {
    return null;
  }
  return new Directory(path);
}

Future gitClone() async {
  print("Going to git clone");
  try {
    await _platform.invokeMethod('gitClone', {
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
    String publicKey = await _platform.invokeMethod('generateSSHKeys', {});
    print("Public Key " + publicKey);
  } on PlatformException catch (e) {
    print("Failed to generateSSHKeys: '${e.message}'.");
  }
}

Future gitPull() async {
  print("Going to git pull");
  try {
    await _platform.invokeMethod('gitPull', {
      'folderName': "journal",
    });
    print("Done");
  } on PlatformException catch (e) {
    print("gitPull Failed: '${e.message}'.");
  }
}

Future gitAdd() async {
  print("Going to git add");
  try {
    await _platform.invokeMethod('gitAdd', {
      'folderName': "journal",
      'filePattern': ".",
    });
    print("Done");
  } on PlatformException catch (e) {
    print("gitAdd Failed: '${e.message}'.");
  }
}

Future gitPush() async {
  print("Going to git push");
  try {
    await _platform.invokeMethod('gitPush', {
      'folderName': "journal",
    });
    print("Done");
  } on PlatformException catch (e) {
    print("gitPush Failed: '${e.message}'.");
  }
}

Future gitCommit() async {
  print("Going to git commit");
  try {
    await _platform.invokeMethod('gitCommit', {
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
