/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:meta/meta.dart';

import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'file.dart';

@immutable
class UnopenedFile extends File {
  final NotesFolderFS parent;

  UnopenedFile({
    required File file,
    required this.parent,
  }) : super(
          oid: file.oid,
          filePath: file.filePath,
          repoPath: file.repoPath,
          modified: file.modified,
          created: file.created,
          fileLastModified: file.fileLastModified,
        );
}
