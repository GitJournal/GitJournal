/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter_test/flutter_test.dart' as ft;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:test/test.dart';

import 'package:gitjournal/logger/fakes/fake_path_provider.dart';
import 'package:gitjournal/logger/logger.dart';

void main() {
  setUp(() async {
    ft.TestWidgetsFlutterBinding.ensureInitialized();

    var provider = await FakePathProviderPlatform.init();
    PathProviderPlatform.instance = provider;
    await Log.init(ignoreFimber: true);
  });

  test('Logger', () async {
    Log.e("Hello");

    try {
      throw Exception("Boo");
    } catch (e, st) {
      Log.e("Caught", ex: e, stacktrace: st);
    }

    var logs = Log.fetchLogsForDate(DateTime.now()).toList();
    expect(logs.length, 2);
    expect(logs[0].msg, "Hello");
    expect(logs[1].msg, "Caught");
  });
}
// todo: Make this async
// todo: Make sure all exceptions are being caught
