/*
 * SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:typed_data';

import 'package:dart_git/blob_ctime_builder.dart';
import 'package:dart_git/dart_git.dart';
import 'package:dart_git/file_mtime_builder.dart';
import 'package:dart_git/utils/date_time.dart';
import 'package:fixnum/fixnum.dart';
import 'package:path/path.dart' as p;
import 'package:universal_io/io.dart' as io;

import 'package:gitjournal/core/file/file.dart';
import 'package:gitjournal/core/file/file_storage.dart';
import 'package:gitjournal/generated/builders.pb.dart' as pb;

class FileStorageCache {
  final String cacheFolderPath;

  FileStorageCache(this.cacheFolderPath) {
    assert(cacheFolderPath.startsWith(p.separator));
  }

  Future<void> clear() async {
    dynamic _;
    _ = await io.File(_cTimeFilePath).delete(recursive: true);
    _ = await io.File(_mTimeFilePath).delete(recursive: true);
  }

  Future<FileStorage> load(GitRepository gitRepo) async {
    var blobVisitor = await _buildCTimeBuilder();
    var mTimeBuilder = await _buildMTimeBuilder();

    // FIXME: Handle FS errors!

    return FileStorage(
      gitRepo: gitRepo,
      blobCTimeBuilder: blobVisitor,
      fileMTimeBuilder: mTimeBuilder,
    );
  }

  Future<void> save(FileStorage fileStorage) async {
    await _saveCTime(fileStorage.blobCTimeBuilder);
    await _saveMTime(fileStorage.fileMTimeBuilder);
  }

  String get _cTimeFilePath => p.join(cacheFolderPath, 'blob_ctime_v1');
  String get _mTimeFilePath => p.join(cacheFolderPath, 'file_mtime_v1');

  Future<BlobCTimeBuilder> _buildCTimeBuilder() async {
    var file = io.File(_cTimeFilePath);
    if (!file.existsSync()) {
      return BlobCTimeBuilder();
    }

    var buffer = await file.readAsBytes();
    var data = pb.BlobCTimeBuilderData.fromBuffer(buffer);

    var commitHashes = data.commitHashes
        .map((bytes) => GitHash.fromBytes(Uint8List.fromList(bytes)))
        .toSet();

    var treeHashes = data.treeHashes
        .map((bytes) => GitHash.fromBytes(Uint8List.fromList(bytes)))
        .toSet();

    var map = data.map
        .map((hashStr, pbDt) => MapEntry(GitHash(hashStr), _fromProto(pbDt)));

    return BlobCTimeBuilder(
      processedCommits: commitHashes,
      processedTrees: treeHashes,
      map: map,
    );
  }

  Future<FileMTimeBuilder> _buildMTimeBuilder() async {
    var file = io.File(_mTimeFilePath);
    if (!file.existsSync()) {
      return FileMTimeBuilder();
    }

    var buffer = await file.readAsBytes();
    var data = pb.FileMTimeBuilderData.fromBuffer(buffer);

    var commitHashes = data.commitHashes
        .map((bytes) => GitHash.fromBytes(Uint8List.fromList(bytes)))
        .toSet();

    var treeHashes = data.treeHashes
        .map((bytes) => GitHash.fromBytes(Uint8List.fromList(bytes)))
        .toSet();

    var map = data.map.map((filePath, pbInfo) {
      var hash = GitHash.fromBytes(Uint8List.fromList(pbInfo.hash));
      var dt = _fromProto(pbInfo.dt);
      var info = FileMTimeInfo(pbInfo.filePath, hash, dt);

      return MapEntry(filePath, info);
    });

    return FileMTimeBuilder(
      processedCommits: commitHashes,
      processedTrees: treeHashes,
      map: map,
    );
  }

  Future<void> _saveCTime(BlobCTimeBuilder builder) async {
    var commitHashes = builder.processedCommits.map((bytes) => bytes.bytes);
    var treeHashes = builder.processedTrees.map((bytes) => bytes.bytes);
    var map = builder.map.map((hash, dt) {
      var pbDt = pb.TzDateTime(
        offset: dt.offset.inSeconds,
        timestamp: Int64(dt.secondsSinceEpoch),
      );
      return MapEntry(hash.toString(), pbDt);
    });

    var data = pb.BlobCTimeBuilderData(
      commitHashes: commitHashes,
      treeHashes: treeHashes,
      map: map,
    );

    var file = io.File(_cTimeFilePath);
    var _ = await file.writeAsBytes(data.writeToBuffer());
  }

  Future<void> _saveMTime(FileMTimeBuilder builder) async {
    var commitHashes = builder.processedCommits.map((bytes) => bytes.bytes);
    var treeHashes = builder.processedTrees.map((bytes) => bytes.bytes);
    var map = builder.map.map((filePath, data) {
      var pbDt = pb.TzDateTime(
        offset: data.dt.offset.inSeconds,
        timestamp: Int64(data.dt.secondsSinceEpoch),
      );

      var info = pb.FileMTimeInfo(
        dt: pbDt,
        hash: data.hash.bytes,
        filePath: filePath,
      );

      return MapEntry(filePath, info);
    });

    var data = pb.FileMTimeBuilderData(
      commitHashes: commitHashes,
      treeHashes: treeHashes,
      map: map,
    );

    var file = io.File(_mTimeFilePath);
    var _ = await file.writeAsBytes(data.writeToBuffer());
  }
}

GDateTime _fromProto(pb.TzDateTime dt) {
  var offset = Duration(seconds: dt.offset);
  return GDateTime.fromTimeStamp(offset, dt.timestamp.toInt());
}
