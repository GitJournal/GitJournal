import 'dart:async';
import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const _platform = const MethodChannel('gitjournal.io/git');

///
/// This gives us the directory where all the git repos will be stored
///
Future<Directory> getGitBaseDirectory() async {
  final String path = await _platform.invokeMethod('getBaseDirectory');
  if (path == null) {
    return null;
  }
  return Directory(path);
}

class GitRepo {
  String folderName;
  String authorName;
  String authorEmail;

  GitRepo({
    @required this.folderName,
    @required this.authorName,
    @required this.authorEmail,
  });

  static Future<void> clone(String folderName, String cloneUrl) async {
    try {
      await _platform.invokeMethod('gitClone', {
        'cloneUrl': cloneUrl,
        'folderName': folderName,
      });
      Fimber.d("Done");
    } on PlatformException catch (e) {
      Fimber.d("gitClone Failed: '${e.message}'.");
      throw createGitException(e.message);
    }
  }

  static Future<void> init(String folderName) async {
    try {
      await _platform.invokeMethod('gitInit', {
        'folderName': folderName,
      });
    } on PlatformException catch (e) {
      Fimber.d("gitInit Failed: '${e.message}'.");
      throw createGitException(e.message);
    }
  }

  Future<void> pull() async {
    try {
      await _platform.invokeMethod('gitPull', {
        'folderName': folderName,
        'authorName': authorName,
        'authorEmail': authorEmail,
      });
      Fimber.d("Done");
    } on PlatformException catch (e) {
      Fimber.d("gitPull Failed: '${e.message}'.");
      throw createGitException(e.message);
    }
  }

  Future<void> add(String filePattern) async {
    try {
      await _platform.invokeMethod('gitAdd', {
        'folderName': folderName,
        'filePattern': filePattern,
      });
    } on PlatformException catch (e) {
      Fimber.d("gitAdd Failed: '${e.message}'.");
    }
  }

  Future<void> rm(String filePattern) async {
    try {
      await _platform.invokeMethod('gitRm', {
        'folderName': folderName,
        'filePattern': filePattern,
      });
    } on PlatformException catch (e) {
      Fimber.d("gitRm Failed: '${e.message}'.");
    }
  }

  Future<void> push() async {
    try {
      await _platform.invokeMethod('gitPush', {
        'folderName': folderName,
      });
    } on PlatformException catch (e) {
      Fimber.d("gitPush Failed: '${e.message}'.");
      throw createGitException(e.message);
    }
  }

  // FIXME: Change this method to just resetHard
  Future<void> resetLast() async {
    try {
      await _platform.invokeMethod('gitResetLast', {
        'folderName': folderName,
      });
    } on PlatformException catch (e) {
      Fimber.d("gitResetLast Failed: '${e.message}'.");
      throw createGitException(e.message);
    }
  }

  // FIXME: Change the datetime
  // FIXME: Actually implement the 'when'
  Future<void> commit({@required String message, String when}) async {
    try {
      await _platform.invokeMethod('gitCommit', {
        'folderName': folderName,
        'authorName': authorName,
        'authorEmail': authorEmail,
        'message': message,
        'when': when,
      });
    } on PlatformException catch (e) {
      Fimber.d("gitCommit Failed: '${e.message}'.");
    }
  }
}

Future<String> generateSSHKeys({@required String comment}) async {
  Fimber.d("generateSSHKeyss: " + comment);
  try {
    String publicKey = await _platform.invokeMethod('generateSSHKeys', {
      'comment': comment,
    });
    Fimber.d("Public Key " + publicKey);
    return publicKey;
  } on PlatformException catch (e) {
    Fimber.d("Failed to generateSSHKeys: '${e.message}'.");
  }

  try {
    String publicKey = await _platform.invokeMethod('getSSHPublicKey');
    Fimber.d("Public Key " + publicKey);
    return publicKey;
  } on PlatformException catch (e) {
    Fimber.d("Failed to getSSHPublicKey: '${e.message}'.");
  }

  return "";
}

Future<void> setSshKeys({
  @required String publicKey,
  @required String privateKey,
}) async {
  Fimber.d("setSshKeys");
  try {
    await _platform.invokeMethod('setSshKeys', {
      'publicKey': publicKey,
      'privateKey': privateKey,
    });
  } on PlatformException catch (e) {
    Fimber.d("Failed to setSSHKeys: '${e.message}'.");
    rethrow;
  }
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
