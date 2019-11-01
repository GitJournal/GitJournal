import 'dart:async';
import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter_crashlytics/flutter_crashlytics.dart';

const _platform = MethodChannel('gitjournal.io/git');

bool shouldIgnorePlatformException(PlatformException ex) {
  var msg = ex.message.toLowerCase();
  if (msg.contains("failed to resolve address for")) {
    return true;
  }
  if (msg.contains("failed to connect to")) {
    return true;
  }
  if (msg.contains("no address associated with hostname")) {
    return true;
  }
  if (msg.contains("failed to connect to")) {
    return true;
  }
  if (msg.contains("unauthorized")) {
    return true;
  }
  if (msg.contains("failed to start ssh session")) {
    return true;
  }
  return false;
}

Future invokePlatformMethod(String method, [dynamic arguments]) async {
  try {
    return await _platform.invokeMethod(method, arguments);
  } on PlatformException catch (e, stacktrace) {
    if (!shouldIgnorePlatformException(e)) {
      await FlutterCrashlytics().logException(e, stacktrace);
    }
    throw e;
  }
}

///
/// This gives us the directory where all the git repos will be stored
///
Future<Directory> getGitBaseDirectory() async {
  final String path = await invokePlatformMethod('getBaseDirectory');
  if (path == null) {
    return null;
  }
  return Directory(path);
}

class GitRepo {
  final String folderName;
  final String authorName;
  final String authorEmail;

  const GitRepo({
    @required this.folderName,
    @required this.authorName,
    @required this.authorEmail,
  });

  static Future<void> clone(String folderName, String cloneUrl) async {
    try {
      await invokePlatformMethod('gitClone', {
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
      await invokePlatformMethod('gitInit', {
        'folderName': folderName,
      });
    } on PlatformException catch (e) {
      Fimber.d("gitInit Failed: '${e.message}'.");
      throw createGitException(e.message);
    }
  }

  Future<void> pull() async {
    try {
      await invokePlatformMethod('gitPull', {
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
      await invokePlatformMethod('gitAdd', {
        'folderName': folderName,
        'filePattern': filePattern,
      });
    } on PlatformException catch (e) {
      Fimber.d("gitAdd Failed: '${e.message}'.");
    }
  }

  Future<void> rm(String filePattern) async {
    try {
      await invokePlatformMethod('gitRm', {
        'folderName': folderName,
        'filePattern': filePattern,
      });
    } on PlatformException catch (e) {
      Fimber.d("gitRm Failed: '${e.message}'.");
    }
  }

  Future<void> push() async {
    try {
      await invokePlatformMethod('gitPush', {
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
      await invokePlatformMethod('gitResetLast', {
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
      await invokePlatformMethod('gitCommit', {
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
    String publicKey = await invokePlatformMethod('generateSSHKeys', {
      'comment': comment,
    });
    Fimber.d("Public Key " + publicKey);
    return publicKey;
  } on PlatformException catch (e) {
    Fimber.d("Failed to generateSSHKeys: '${e.message}'.");
  }

  try {
    String publicKey = await invokePlatformMethod('getSSHPublicKey');
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
    await invokePlatformMethod('setSshKeys', {
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
