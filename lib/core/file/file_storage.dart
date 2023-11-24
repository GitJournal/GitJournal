/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:isolate';

import 'package:dart_git/blob_ctime_builder.dart';
import 'package:dart_git/dart_git.dart';
import 'package:dart_git/exceptions.dart';
import 'package:dart_git/file_mtime_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:tuple/tuple.dart';
import 'package:universal_io/io.dart' as io;

import 'file.dart';

class FileStorage with ChangeNotifier {
  late final String repoPath;

  final BlobCTimeBuilder blobCTimeBuilder;
  final FileMTimeBuilder fileMTimeBuilder;

  var _dateTime = DateTime.now();
  DateTime get dateTime => _dateTime;

  var head = GitHash.zero();

  FileStorage({
    required String repoPath,
    required this.blobCTimeBuilder,
    required this.fileMTimeBuilder,
  }) {
    this.repoPath =
        repoPath.endsWith(p.separator) ? repoPath : repoPath + p.separator;
  }

  Future<File> load(String filePath) async {
    assert(!filePath.startsWith(p.separator));
    var fullFilePath = p.join(repoPath, filePath);

    assert(fileMTimeBuilder.map.isNotEmpty, "Trying to load $filePath");
    assert(blobCTimeBuilder.map.isNotEmpty, "Trying to load $filePath");

    var ioFile = io.File(fullFilePath);
    var stat = ioFile.statSync();
    if (stat.type == io.FileSystemEntityType.notFound) {
      throw Exception("File note found - $fullFilePath");
    }

    if (stat.type != io.FileSystemEntityType.file) {
      // FIXME: Better error!
      throw Exception('File is not file. Is ${stat.type}');
    }

    var mTimeInfo = fileMTimeBuilder.info(filePath);
    if (mTimeInfo == null) {
      Log.e("Failed to build path: $filePath");
      throw FileStorageCacheIncomplete(filePath);
    }

    var oid = mTimeInfo.hash;
    var modified = mTimeInfo.dt;

    assert(oid.isNotEmpty);

    var created = blobCTimeBuilder.cTime(oid);
    if (created == null) {
      throw Exception('when can this happen?');
    }

    return File(
      oid: oid,
      filePath: filePath,
      repoPath: repoPath,
      fileLastModified: stat.modified,
      created: created,
      modified: modified,
    );
  }

  Future<void> fill() async {
    var rp = ReceivePort();
    rp.listen((d) {
      if (d is DateTime) {
        _dateTime = d;
        notifyListeners();
      }
    });

    var resp = await compute(
      _fillFileStorage,
      _FillFileStorageParams(
        rp.sendPort,
        repoPath,
        blobCTimeBuilder,
        fileMTimeBuilder,
      ),
    );
    rp.close();

    // FIXME: Handle this case of having an error!
    assert(resp != null);
    if (resp == null) return;

    blobCTimeBuilder.update(resp.item1);
    fileMTimeBuilder.update(resp.item2);
    head = resp.item3;
    notifyListeners();
  }

  @visibleForTesting
  static Future<FileStorage> fake(String rootFolder) async {
    assert(rootFolder.startsWith(p.separator));

    GitRepository.init(rootFolder);

    var blobVisitor = BlobCTimeBuilder();
    var mTimeBuilder = FileMTimeBuilder();

    try {
      var repo = GitRepository.load(rootFolder);
      var headHash = repo.headHash();
      var multi = MultiTreeEntryVisitor([blobVisitor, mTimeBuilder]);
      repo.visitTree(fromCommitHash: headHash, visitor: multi);
    } catch (ex, stackTrace) {
      Log.e("Failed to load repo or get headHash",
          ex: ex, stacktrace: stackTrace);
    }
    // assert(!headHashR.isFailure, "Failed to get head hash");

    var repoPath = rootFolder.endsWith(p.separator)
        ? rootFolder
        : rootFolder + p.separator;

    return FileStorage(
      repoPath: repoPath,
      blobCTimeBuilder: blobVisitor,
      fileMTimeBuilder: mTimeBuilder,
    );
  }

  @visibleForTesting
  Future<void> reload() async {
    await fill();
  }
}

class FileStorageCacheIncomplete implements Exception {
  final String path;
  FileStorageCacheIncomplete(this.path);
}

typedef _FillFileStorageParams
    = Tuple4<SendPort, String, BlobCTimeBuilder, FileMTimeBuilder>;

typedef _FillFileStorageOutput
    = Tuple3<BlobCTimeBuilder, FileMTimeBuilder, GitHash>;

_FillFileStorageOutput? _fillFileStorage(_FillFileStorageParams params) {
  var sendPort = params.item1;
  var repoPath = params.item2;
  var blobCTimeBuilder = params.item3;
  var fileMTimeBuilder = params.item4;

  var dateTime = DateTime.now();
  var visitor = MultiTreeEntryVisitor(
    [blobCTimeBuilder, fileMTimeBuilder],
    afterCommitCallback: (commit) {
      var commitDt = commit.author.date;
      if (commitDt.isBefore(dateTime)) {
        dateTime = commitDt;
        sendPort.send(dateTime);
      }
    },
  );

  var gitRepo = GitRepository.load(repoPath);
  try {
    var head = gitRepo.headHash();
    Log.d("Got HEAD: $head");

    gitRepo.visitTree(fromCommitHash: head, visitor: visitor);
    return _FillFileStorageOutput(blobCTimeBuilder, fileMTimeBuilder, head);
  } catch (ex, st) {
    if (ex is GitRefNotFound) {
      return _FillFileStorageOutput(
        blobCTimeBuilder,
        fileMTimeBuilder,
        GitHash.zero(),
      );
    }
    logException(ex, st);

    return null;
  }
}
