import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:git_bindings/git_bindings.dart';

import 'package:gitjournal/settings.dart';
import 'package:gitjournal/utils/logger.dart';
import 'package:path/path.dart' as p;

//
// FIXME: This isn't ideal as we are skipping all the edits / deletes
//
Future migrateGitRepo({
  @required String gitBasePath,
  @required String fromGitBasePath,
  @required String toGitBaseFolder,
}) async {
  Log.d("migrateGitRepo $fromGitBasePath $toGitBaseFolder");
  var fromBasePath = p.join(gitBasePath, fromGitBasePath);
  var toGitRepoPath = p.join(gitBasePath, toGitBaseFolder);
  Log.d("toGitRemotePath $toGitRepoPath");

  final dir = Directory(fromBasePath);
  var lister = dir.list(recursive: false);
  await for (var fileEntity in lister) {
    if (fileEntity is! File) {
      continue;
    }
    File file = fileEntity;
    var fileName = p.basename(file.path);
    var toPath = p.join(toGitRepoPath, fileName);

    Log.d("Migrating " + file.path + " --> " + toPath);

    await file.copy(toPath);

    var gitRepo = GitRepo(
      folderPath: toGitRepoPath,
      authorEmail: Settings.instance.gitAuthorEmail,
      authorName: Settings.instance.gitAuthor,
    );
    await gitRepo.add(fileName);
    await gitRepo.commit(message: "Added Note");
  }
  Log.d("migrateGitRepo: Done");
}
