/*
 * SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:universal_io/io.dart' as io;

Future<void> saveFileSafely(String filePath, List<int> bytes) async {
  var newFilePath = '$filePath.new';

  var file = io.File(newFilePath);
  await file.writeAsBytes(bytes);
  await file.rename(filePath);
}
