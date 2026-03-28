/*
 * SPDX-FileCopyrightText: 2026 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitjournal/settings/markdown_renderer_config.dart';
import 'package:gitjournal/widgets/images/markdown_image.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../lib.dart';

void main() {
  setUpAll(gjSetupAllTests);

  testWidgets('Respects image size from markdown title', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final pref = await SharedPreferences.getInstance();
    final config = MarkdownRendererConfig('test', pref)..load();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: config,
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: MarkdownImage(
                Uri.parse('./testdata/icon.png'),
                '.',
                titel: '50%',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.width, 100);
  });
}
