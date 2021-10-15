/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:dart_git/blob_ctime_builder.dart';
import 'package:dart_git/dart_git.dart';
import 'package:dart_git/plumbing/git_hash.dart';
import 'package:dart_git/plumbing/index.dart';
import 'package:universal_io/io.dart' as io;

import 'file.dart';

class FileStorage {
  final String repoPath;
  final GitRepository gitRepo;
  final GitIndex gitIndex;
  final BlobCTimeBuilder blobCTimeBuilder;

  GitHash? head;

  FileStorage({
    required this.gitRepo,
    required this.gitIndex,
    required this.blobCTimeBuilder,
  }) : repoPath = gitRepo.workTree;

  Future<Result<File>> load(String filePath) async {
    assert(!filePath.startsWith('/'));

    var ioFile = io.File(filePath);
    var stat = ioFile.statSync();
    if (stat.type != io.FileSystemEntityType.file) {
      // FIXME: Better error!
      var ex = Exception('File is not file');
      return Result.fail(ex);
    }

    // FIXME: Do a more through check?
    // FIXME: Add an 'entryWhere' helper function
    var entry = gitIndex.entryWhere((e) => e.path == filePath);
    var oid = entry != null ? entry.hash : GitHash.zero();

    // FIXME: Should we be computing the hash in this case?

    // FIXME: handle case when oid is zero!
    var modified = blobCTimeBuilder.cTime(oid);
    if (modified == null) {
      var ex = Exception('when can this happen?');
      return Result.fail(ex);
    }

    // TODO: FilePathCTimeBuilder();
    var created = modified;

    return Result(File(
      oid: oid,
      filePath: filePath,
      fileLastModified: stat.modified,
      created: created,
      modified: modified,
    ));
  }
}
