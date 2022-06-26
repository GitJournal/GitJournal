/*
 * SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:dart_git/utils/result.dart';
import 'package:universal_io/io.dart' as io;

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
