/*
 * SPDX-FileCopyrightText: 2023 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitjournal/iap/purchase_thankyou_screen.dart';
import 'package:gitjournal/screens/onboarding_screens.dart';
import 'package:gitjournal/settings/settings_screen.dart';
import 'package:widgetbook/widgetbook.dart';

Future<void> _defaultOnCreate(WidgetTester tester) async {}
typedef BuilderFn = Widget Function(BuildContext);

class TestScreen {
  final String name;
  final BuilderFn builder;

  @Deprecated('Should not be committed')
  final bool solo;
  final bool skipGolden;
  final bool skipWidgetBook;
  final Future<void> Function(WidgetTester tester) onCreate;

  TestScreen({
    required this.name,
    required this.builder,
    this.solo = false,
    this.skipGolden = false,
    this.skipWidgetBook = false,
    this.onCreate = _defaultOnCreate,
  });
}

class TestScreenGroup {
  final String name;
  final List<TestScreen> screens;

  TestScreenGroup({required this.name, required this.screens});

  // ignore: deprecated_member_use_from_same_package
  bool get hasSolo => screens.firstWhereOrNull((s) => s.solo == true) != null;
}

typedef BuildDepsFn = Widget Function(BuildContext, Widget child);

WidgetbookCategory buildWidgetbookCategory(
  String name,
  List<TestScreenGroup> allScreens,
  BuildDepsFn buildDeps,
) {
  return WidgetbookCategory(
    name: name,
    widgets: [
      for (var group in allScreens)
        WidgetbookComponent(
          name: group.name,
          isExpanded: true,
          useCases: [
            for (var screen in group.screens)
              if (!screen.skipWidgetBook)
                WidgetbookUseCase(
                  name: screen.name,
                  builder: (context) => buildDeps(
                    context,
                    Builder(builder: screen.builder),
                  ),
                ),
          ],
        ),
    ],
  );
}

var allScreens = [
  TestScreenGroup(name: "OnBoarding", screens: [
    TestScreen(
      name: "Page 1",
      builder: (context) => const OnBoardingScreen(
        skipPage1: false,
        skipPage2: false,
        skipPage3: false,
      ),
    ),
    TestScreen(
      name: "Page 2",
      builder: (context) => const OnBoardingScreen(
        skipPage1: true,
        skipPage2: false,
        skipPage3: false,
      ),
    ),
    TestScreen(
      name: "Page 3",
      builder: (context) => const OnBoardingScreen(
        skipPage1: true,
        skipPage2: true,
        skipPage3: false,
      ),
    ),
  ]),
  TestScreenGroup(name: "Payment", screens: [
    TestScreen(name: "Thank You", builder: (_) => PurchaseThankYouScreen()),
  ]),
  TestScreenGroup(name: "Settings", screens: [
    TestScreen(name: "Home", builder: (_) => SettingsScreen()),
  ]),
];
