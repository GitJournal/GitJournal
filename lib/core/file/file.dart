/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/foundation.dart';

import 'package:dart_git/plumbing/git_hash.dart';
import 'package:path/path.dart' as p;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:quiver/core.dart';

import 'package:gitjournal/generated/core.pb.dart' as pb;
import 'package:gitjournal/utils/datetime.dart';

export 'package:dart_git/plumbing/git_hash.dart';

class File {
  final GitHash oid;
  final String repoPath;
  final String filePath;

  String get fullFilePath => p.join(repoPath, filePath);

  final DateTime modified;
  final DateTime created;

  // Maybe attach the entire GitFileIndex?
  final DateTime fileLastModified;

  // I would attach the entire file stat's result

  File({
    required this.oid,
    required this.filePath,
    required this.repoPath,
    required this.modified,
    required this.created,
    required this.fileLastModified,
  }) {
    assert(repoPath.isNotEmpty);
    assert(filePath.isNotEmpty);
  }

  @visibleForTesting
  File.short(this.filePath, this.repoPath)
      : oid = GitHash.zero(),
        fileLastModified = DateTime.now(),
        modified = DateTime.now(),
        created = DateTime.now() {
    assert(!filePath.startsWith(p.separator));

    assert(repoPath.startsWith(p.separator));
    assert(repoPath.endsWith(p.separator));
  }

  File.empty({required this.repoPath})
      : filePath = '',
        oid = GitHash.zero(),
        fileLastModified = DateTime.now(),
        modified = DateTime.now(),
        created = DateTime.now() {
    assert(repoPath.startsWith(p.separator));
    assert(repoPath.endsWith(p.separator));
  }

  String get fileName => p.basename(filePath);

  File copyFile({
    GitHash? oid,
    String? filePath,
    DateTime? modified,
    DateTime? created,
    DateTime? fileLastModified,
  }) {
    assert(repoPath.isNotEmpty);
    assert(filePath != null ? filePath.isNotEmpty : true);

    return File(
      oid: oid ?? this.oid,
      repoPath: repoPath,
      filePath: filePath ?? this.filePath,
      modified: modified ?? this.modified,
      created: created ?? this.created,
      fileLastModified: fileLastModified ?? this.fileLastModified,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is File &&
          runtimeType == other.runtimeType &&
          oid == other.oid &&
          repoPath == other.repoPath &&
          filePath == other.filePath &&
          modified == other.modified &&
          created == other.created &&
          fileLastModified == other.fileLastModified;

  @override
  int get hashCode => hashObjects(
      [oid, repoPath, filePath, created, modified, fileLastModified]);

  @override
  String toString() =>
      'File{oid: $oid, filePath: $filePath, created: $created, modified: $modified, fileLastModified: $fileLastModified}';

  $pb.GeneratedMessage toProtoBuf() {
    return pb.File(
      repoPath: repoPath,
      hash: oid.bytes,
      filePath: filePath,
      modified: modified.toProtoBuf(),
      created: created.toProtoBuf(),
      fileLastModified: fileLastModified.toProtoBuf(),
    );
  }

  static File fromProtoBuf(pb.File pbFile) {
    return File(
      repoPath: pbFile.repoPath,
      oid: GitHash.fromBytes(pbFile.hash),
      filePath: pbFile.filePath,
      created: pbFile.created.toDateTime(),
      modified: pbFile.modified.toDateTime(),
      fileLastModified: pbFile.fileLastModified.toDateTime(),
    );
  }
}

// on save - compute hash, and commit, only then should we add it to the parent
//           dir? -> This can get expensive!
//

// FolderView -> make it show IgnoredFiles as well
//            -> When clicking on an IgnoredFile allow it to be opened
//               via the RawEditor

// RawEditor(File file) -> add supports(File file)

// TextFile can have the (text + encoding) + File
//   alternatives -> body / data

// Image should also be a file

// The NewNote FAB can have more options .. ?

// Remove the 'Note' class entrirely

// With this, we can easily add 'grpc' support for the 'loaders' of each of
// these 'Files'.

// And then the only thing left would be 'Repository' and 'RepositoryManager'
