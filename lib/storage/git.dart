import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const _platform = const MethodChannel('gitjournal.io/git');

Future<Directory> getGitBaseDirectory() async {
  final String path = await _platform.invokeMethod('getBaseDirectory');
  if (path == null) {
    return null;
  }
  return new Directory(path);
}

Future<String> gitClone(String cloneUrl, String folderName) async {
  print("Going to git clone");
  try {
    await _platform.invokeMethod('gitClone', {
      'cloneUrl': cloneUrl,
      'folderName': folderName,
    });
    print("Done");
  } on PlatformException catch (e) {
    print("gitClone Failed: '${e.message}'.");
    return e.message;
  }

  return null;
}

Future<String> generateSSHKeys({@required String comment}) async {
  print("generateSSHKeyss: " + comment);
  try {
    String publicKey = await _platform.invokeMethod('generateSSHKeys', {
      'comment': comment,
    });
    print("Public Key " + publicKey);
    return publicKey;
  } on PlatformException catch (e) {
    print("Failed to generateSSHKeys: '${e.message}'.");
  }

  try {
    String publicKey = await _platform.invokeMethod('getSSHPublicKey', {});
    print("Public Key " + publicKey);
    return publicKey;
  } on PlatformException catch (e) {
    print("Failed to getSSHPublicKey: '${e.message}'.");
  }

  return "";
}

class GitException implements Exception {
  final String cause;
  GitException(this.cause);

  @override
  String toString() {
    return "GitException: " + cause;
  }
}

GitException createGitException(String msg) {
  if (msg.contains("ENETUNREACH")) {
    return GitException("No Connection");
  }
  if (msg.contains("Remote origin did not advertise Ref for branch master")) {
    return GitException("No master branch");
  }
  if (msg.contains("Nothing to push")) {
    return GitException("Nothing to push.");
  }
  return GitException(msg);
}

Future gitPull(String folderName) async {
  print("Going to git pull");
  try {
    await _platform.invokeMethod('gitPull', {
      'folderName': folderName,
    });
    print("Done");
  } on PlatformException catch (e) {
    print("gitPull Failed: '${e.message}'.");
    throw createGitException(e.message);
  }
}

Future gitAdd(String gitFolder, String filePattern) async {
  print("Going to git add: " + filePattern);
  try {
    await _platform.invokeMethod('gitAdd', {
      'folderName': gitFolder,
      'filePattern': filePattern,
    });
    print("Done");
  } on PlatformException catch (e) {
    print("gitAdd Failed: '${e.message}'.");
  }
}

Future gitRm(String gitFolder, String filePattern) async {
  print("Going to git rm");
  try {
    await _platform.invokeMethod('gitRm', {
      'folderName': gitFolder,
      'filePattern': filePattern,
    });
    print("Done");
  } on PlatformException catch (e) {
    print("gitRm Failed: '${e.message}'.");
  }
}

Future gitPush(String folderName) async {
  print("Going to git push");
  try {
    await _platform.invokeMethod('gitPush', {
      'folderName': folderName,
    });
    print("Done");
  } on PlatformException catch (e) {
    print("gitPush Failed: '${e.message}'.");
    throw createGitException(e.message);
  }
}

Future gitCommit({
  String gitFolder,
  String authorName,
  String authorEmail,
  String message,
}) async {
  print("Going to git commit");
  try {
    await _platform.invokeMethod('gitCommit', {
      'folderName': gitFolder,
      'authorName': authorName,
      'authorEmail': authorEmail,
      'message': message,
    });
    print("Done");
  } on PlatformException catch (e) {
    print("gitCommit Failed: '${e.message}'.");
  }
}

Future gitInit(String folderName) async {
  print("Going to git init");
  try {
    await _platform.invokeMethod('gitInit', {
      'folderName': folderName,
    });
    print("Done");
  } on PlatformException catch (e) {
    print("gitInit Failed: '${e.message}'.");
    throw createGitException(e.message);
  }
}
