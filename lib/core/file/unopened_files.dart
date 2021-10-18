/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'file.dart';

class UnopenedFile extends File {
  NotesFolderFS parent;

  UnopenedFile({
    required GitHash oid,
    required String filePath,
    required DateTime? modified,
    required DateTime? created,
    required DateTime fileLastModified,
    required this.parent,
  }) : super(
          oid: oid,
          filePath: filePath,
          modified: modified,
          created: created,
          fileLastModified: fileLastModified,
        );
}
