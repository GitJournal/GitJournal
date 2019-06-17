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
  @required String toGitBaseFolder,
  @required String toGitBaseSubFolder,
}) async {
  print(
      "migrateGitRepo $fromGitBasePath $toGitBaseFolder / $toGitBaseSubFolder");
  var fromBasePath = p.join(gitBasePath, fromGitBasePath);
  var toGitRepoPath = p.join(gitBasePath, toGitBaseFolder, toGitBaseSubFolder);
  print("toGitRemotePath $toGitRepoPath");

  final dir = Directory(fromBasePath);
  var lister = dir.list(recursive: false);
  await for (var fileEntity in lister) {
    if (fileEntity is! File) {
      continue;
    }
    File file = fileEntity;
    var fileName = p.basename(file.path);
    var toPath = p.join(toGitRepoPath, fileName);

    print("Migrating " + file.path + " --> " + toPath);

    await file.copy(toPath);

    var gitRepo = GitRepo(
      folderName: toGitBaseFolder,
      authorEmail: Settings.instance.gitAuthorEmail,
      authorName: Settings.instance.gitAuthor,
    );
    await gitRepo.add(fileName);
    await gitRepo.commit(message: "Added Journal Entry");
  }
  print("migrateGitRepo: Done");
}
