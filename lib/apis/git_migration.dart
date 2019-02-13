import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:journal/apis/git.dart';
import 'package:journal/settings.dart';
import 'package:path/path.dart' as p;

//
// FIXME: This isn't ideal as we are skipping all the edits / deletes
//
Future migrateGitRepo({
  @required String gitBasePath,
  @required String fromGitBasePath,
  @required String toGitBasePath,
}) async {
  print("migrateGitRepo " + fromGitBasePath + " " + toGitBasePath);
  var fromBasePath = p.join(gitBasePath, fromGitBasePath);
  var toBasePath = p.join(gitBasePath, toGitBasePath);

  final dir = Directory(fromBasePath);
  var lister = dir.list(recursive: false);
  await for (var fileEntity in lister) {
    if (fileEntity is! File) {
      continue;
    }
    File file = fileEntity;
    var fileName = p.basename(file.path);
    var toPath = p.join(toBasePath, fileName);

    print("Migrating " + file.path + " --> " + toPath);

    await file.copy(toPath);
    await gitAdd(toGitBasePath, fileName);
    await gitCommit(
      gitFolder: toGitBasePath,
      authorEmail: Settings.instance.gitAuthorEmail,
      authorName: Settings.instance.gitAuthor,
      message: "Migrated Journal Entry",
    );
  }
  print("migrateGitRepo: Done");
}
