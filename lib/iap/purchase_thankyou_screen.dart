/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:gitjournal/generated/locale_keys.g.dart';

class PurchaseThankYouScreen extends StatelessWidget {
  static const routePath = '/purchase_thank_you';

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    Widget w = Column(
      children: <Widget>[
        Text(
          tr(LocaleKeys.purchase_screen_thanks_title),
          style: textTheme.headline3,
        ),
        Text(
          tr(LocaleKeys.purchase_screen_thanks_subtitle),
          style: textTheme.headline4,
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(64.0, 16.0, 64.0, 16.0),
          child: ElevatedButton(
            child: const Text("Back"),
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).primaryColor),
            ),
          ),
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceAround,
    );

    return Container(
      child: SafeArea(child: w),
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.all(16.0),
    );
  }
}

// Ideas:
// 1. Add a button to share about GitJournal on Twitter / Social Media over here
