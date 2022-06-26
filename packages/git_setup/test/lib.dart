/*
 * SPDX-FileCopyrightText: 2022 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:io';

import 'package:gitjournal/logger/logger.dart';

final inCI = Platform.environment.containsKey("CI");

Future<void> gjSetupAllTests() async {
  if (!inCI) {
    return;
  }

  final logsCacheDir = await Directory.systemTemp.createTemp();
  await Log.init(cacheDir: logsCacheDir.path, ignoreFimber: false);
}
