/*
 * SPDX-FileCopyrightText: 2022 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter_test/flutter_test.dart';

import 'package:gitjournal/setup/git_transfer_progress.dart';
import '../lib.dart';

void main() {
  setUpAll(gjSetupAllTests);

  test('Simple', () {
    var p = GitTransferProgress.parse('6793 1993 2071 0 0 0 434727')!;

    expect(p.networkText, 'network 30.49% (424 kb, 2071/6793)');
    expect(p.indexText, 'index 29.34% (1993/6793)');
  });
}
