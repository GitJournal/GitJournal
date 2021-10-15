/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:dart_git/plumbing/git_hash.dart';

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
  }) {
    assert(!filePath.startsWith('/'));
  }

  // Add toString
}

// TODO: Add a cache for FilePathCTimeBuilder and the blob one
//       This caches needs to be saved to disk

//
// We need to store the top commit it has processed, and add a method to make
// it process more commits
//

class NewNote {
  File? file;
  String? newBody;
}

// on save - compute hash, and commit, only then should we add it to the parent
//           dir? -> This can get expensive!
//

// NotesFolderFS
// -> Iterate and load all the files from FileStorage
// -> Load all the Notes
//    -> The File becomes either a Note or an IgnoredFile
//    -> NotesFolder interface returns Files (not Notes)
// -> Each Note contains a 'File' for now
//    or make a Note inheirt from a 'File' or implement its interface
//    I prefer the interace option as then .. what ?
//
// This is the smallest modification that can be done

// Once this is done, then also modify IgnoredFile to have the same interface

// FolderView -> make it show IgnoredFiles as well
//            -> When clicking on an IgnoredFile allow it to be opened
//               via the RawEditor

// RawEditor(File file) -> add supports(File file)


// TextFile can have the (text + encoding) + File
// -> allText?
//   Calling the member 'text' doesn't feel right
//   alternatives -> body / data


// Image should also be a file

// The NewNote FAB can have more options .. ?


// Git modified / created will be fixed
// I can create specific "Views" for files
// -> a 'Note' can be a TextFile
// NO - Remove the 'Note' class completely

// With this, we can easily add 'grpc' support for the 'loaders' of each of
// these 'Files'.

// And then the only thing left would be 'Repository' and 'RepositoryManager'
