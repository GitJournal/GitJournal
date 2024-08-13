/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:gitjournal/l10n.dart';

class PurchaseThankYouScreen extends StatelessWidget {
  static const routePath = '/purchase_thank_you';

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    Widget w = Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Text(
          context.loc.purchaseScreenThanksTitle,
          style: textTheme.displaySmall,
        ),
        Text(
          context.loc.purchaseScreenThanksSubtitle,
          style: textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(64.0, 16.0, 64.0, 16.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(
                  Theme.of(context).primaryColor),
            ),
            child: const Text("Back"),
          ),
        ),
      ],
    );

    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.all(16.0),
      child: SafeArea(child: w),
    );
  }
}

// Ideas:
// 1. Add a button to share about GitJournal on Twitter / Social Media over here
