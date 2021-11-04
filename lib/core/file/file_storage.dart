/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:dart_git/blob_ctime_builder.dart';
import 'package:dart_git/dart_git.dart';
import 'package:dart_git/file_mtime_builder.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:universal_io/io.dart' as io;

import 'file.dart';

class FileStorage {
  final String repoPath;
  final GitRepository gitRepo;

  final BlobCTimeBuilder blobCTimeBuilder;
  final FileMTimeBuilder fileMTimeBuilder;

  MultiTreeEntryVisitor get visitor => MultiTreeEntryVisitor([
        blobCTimeBuilder,
        fileMTimeBuilder,
      ]);

  FileStorage({
    required this.gitRepo,
    required this.blobCTimeBuilder,
    required this.fileMTimeBuilder,
  }) : repoPath = gitRepo.workTree;

  Future<Result<File>> load(String filePath) async {
    assert(!filePath.startsWith(p.separator));
    var fullFilePath = p.join(repoPath, filePath);

    assert(fileMTimeBuilder.map.isNotEmpty);
    assert(blobCTimeBuilder.map.isNotEmpty);

    var ioFile = io.File(fullFilePath);
    var stat = ioFile.statSync();
    if (stat.type == io.FileSystemEntityType.notFound) {
      var ex = Exception("File note found - $fullFilePath");
      return Result.fail(ex);
    }

    if (stat.type != io.FileSystemEntityType.file) {
      // FIXME: Better error!
      var ex = Exception('File is not file. Is ${stat.type}');
      return Result.fail(ex);
    }

    var mTimeInfo = fileMTimeBuilder.info(filePath);
    if (mTimeInfo == null) {
      var ex = Exception('fileMTimeBuilder failed to find path');
      return Result.fail(ex);
    }

    var oid = mTimeInfo.hash;
    var modified = mTimeInfo.dt;

    var created = blobCTimeBuilder.cTime(oid);
    if (created == null) {
      var ex = Exception('when can this happen?');
      return Result.fail(ex);
    }

    return Result(File(
      oid: oid,
      filePath: filePath,
      repoPath: repoPath,
      fileLastModified: stat.modified,
      created: created,
      modified: modified,
    ));
  }

  @visibleForTesting
  static Future<FileStorage> fake(String rootFolder) async {
    assert(rootFolder.startsWith(p.separator));

    await GitRepository.init(rootFolder).throwOnError();

    var blobVisitor = BlobCTimeBuilder();
    var mTimeBuilder = FileMTimeBuilder();

    var repo = await GitRepository.load(rootFolder).getOrThrow();
    var result = await repo.headHash();
    if (result.isSuccess) {
      var multi = MultiTreeEntryVisitor([blobVisitor, mTimeBuilder]);
      await repo
          .visitTree(fromCommitHash: result.getOrThrow(), visitor: multi)
          .throwOnError();
    }
    // assert(!headHashR.isFailure, "Failed to get head hash");

    return FileStorage(
      gitRepo: repo,
      blobCTimeBuilder: blobVisitor,
      fileMTimeBuilder: mTimeBuilder,
    );
  }

  @visibleForTesting
  Future<Result<void>> reload() async {
    var result = await gitRepo.headHash();
    if (result.isFailure) {
      return fail(result);
    }
    var headHash = result.getOrThrow();

    var multi = MultiTreeEntryVisitor([blobCTimeBuilder, fileMTimeBuilder]);
    await gitRepo
        .visitTree(fromCommitHash: headHash, visitor: multi)
        .throwOnError();
    return Result(null);
  }
}
