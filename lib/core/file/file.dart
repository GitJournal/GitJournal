/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:dart_git/plumbing/git_hash.dart';
import 'package:path/path.dart' as p;
import 'package:quiver/core.dart';

import 'package:gitjournal/utils/datetime.dart';

export 'package:dart_git/plumbing/git_hash.dart';

class File {
  final GitHash oid;
  final String filePath;

  // FIXME: These should not be nullable
  final DateTime? modified;
  final DateTime? created;

  // Maybe attach the entire GitFileIndex?
  final DateTime fileLastModified;

  // I would attach the entire file stat's result

  File({
    required this.oid,
    required this.filePath,
    required this.modified,
    required this.created,
    required this.fileLastModified,
  });

  File.short(this.filePath)
      : oid = GitHash.zero(),
        fileLastModified = DateTime.now(),
        modified = null,
        created = null;

  String get fileName => p.basename(filePath);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is File &&
          runtimeType == other.runtimeType &&
          oid == other.oid &&
          filePath == other.filePath &&
          modified == other.modified &&
          created == other.created &&
          fileLastModified == other.fileLastModified;

  @override
  int get hashCode =>
      hashObjects([oid, filePath, created, modified, fileLastModified]);

  @override
  String toString() =>
      'File{oid: $oid, filePath: $filePath, created: $created, modified: $modified, fileLastModified: $fileLastModified}';

  // Add toString
  Map<String, dynamic> toMap() {
    return {
      'oid': oid.toString(),
      'filePath': filePath,
      'modified': modified?.toIso8601String(), // FIXME: Does this have the tz?
      'created': created?.toIso8601String(),
      'fileLastModified': fileLastModified.toIso8601String(),
    };
  }

  static File fromMap(Map<String, dynamic> map) {
    // oid
    var oidV = map['oid'];
    if (oidV == null) {
      return throw Exception('Missing oid');
    }
    if (oidV is! String) {
      return throw Exception('Invalid Type oid');
    }
    var oid = GitHash(oidV);

    // filePath
    var filePath = map['filePath'];
    if (filePath == null) {
      return throw Exception('Missing filePath');
    }
    if (filePath is! String) {
      return throw Exception('Invalid Type filePath');
    }

    // modified
    DateTime? modified;
    var modifiedV = map['modified'];
    if (modifiedV != null) {
      modified = parseDateTime(modifiedV);
    }

    // created
    DateTime? created;
    var createdV = map['created'];
    if (createdV != null) {
      created = parseDateTime(createdV);
    }

    // fileLastModified
    DateTime? fileLastModified;
    var fileLastModifiedV = map['fileLastModified'];
    if (fileLastModifiedV != null) {
      fileLastModified = parseDateTime(fileLastModifiedV);
      if (fileLastModified == null) {
        return throw Exception('Invalid Type fileLastModified');
      }
    } else {
      return throw Exception('Missing fileLastModified');
    }

    return File(
      oid: oid,
      filePath: filePath,
      modified: modified,
      created: created,
      fileLastModified: fileLastModified,
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
