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
    required GitHash oid,
    required String filePath,
    required DateTime? modified,
    required DateTime? created,
    required DateTime fileLastModified,
    required this.reason,
    this.customError,
  }) : super(
          oid: oid,
          filePath: filePath,
          modified: modified,
          created: created,
          fileLastModified: fileLastModified,
        );
}
