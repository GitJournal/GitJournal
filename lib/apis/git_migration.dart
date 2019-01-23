import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:journal/storage/git.dart';

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

  final dir = new Directory(fromBasePath);
  var lister = dir.list(recursive: false);
  await for (var fileEntity in lister) {
    if (fileEntity is! File) {
      continue;
    }
    var file = fileEntity as File;
    var fileName = p.basename(file.path);
    var toPath = p.join(toBasePath, fileName);

    print("Migrating " + file.path + " --> " + toPath);

    await file.copy(toPath);
    await gitAdd(toGitBasePath, fileName);
    await gitCommit(
      gitFolder: toGitBasePath,
      authorEmail: "app@gitjournal.io",
      authorName: "GitJournal",
      message: "Migrated Journal Entry",
    );
  }
  print("migrateGitRepo: Done");
}
