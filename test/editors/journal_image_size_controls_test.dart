/*
 * SPDX-FileCopyrightText: 2026 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitjournal/editors/journal_image_size_controls.dart';

import '../lib.dart';

void main() {
  setUpAll(gjSetupAllTests);

  testWidgets('Updates image markdown size fragment from controls',
      (tester) async {
    final controller = TextEditingController(
      text: '![Image](./example.jpg)',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JournalImageSizeControls(
            textController: controller,
            onChanged: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, '50%'));
    await tester.pumpAndSettle();
    expect(controller.text, '![Image](./example.jpg "50%")');

    await tester.tap(find.widgetWithText(ChoiceChip, '100%'));
    await tester.pumpAndSettle();
    expect(controller.text, '![Image](./example.jpg)');
  });
}
