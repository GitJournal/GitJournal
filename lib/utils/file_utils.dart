/*
 * SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:universal_io/io.dart' as io;

import 'package:git_setup/apis/githost.dart';

Future<Result<void>> saveFileSafely(String filePath, List<int> bytes) {
  return catchAll(() async {
    var newFilePath = filePath + '.new';

    var file = io.File(newFilePath);
    dynamic _;
    _ = await file.writeAsBytes(bytes);
    _ = await file.rename(filePath);

    return Result(null);
  });
}
