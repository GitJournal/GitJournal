/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import '../file/file.dart';

enum IgnoreReason {
  HiddenFile,
  InvalidExtension,
  InvalidEncoding,
  Custom,
}

class IgnoredFile extends File {
  final IgnoreReason reason;
  final Object? customError;

  IgnoredFile({
    required File file,
    required this.reason,
    this.customError,
  }) : super(
          oid: file.oid,
          filePath: file.filePath,
          repoPath: file.repoPath,
          modified: file.modified,
          created: file.created,
          fileLastModified: file.fileLastModified,
        );
}
