/*
 * SPDX-FileCopyrightText: 2019-2022 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:gitjournal/iap/iap.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/settings/app_config.dart';
import 'package:provider/provider.dart';

class RestorePurchaseButton extends StatefulWidget {
  const RestorePurchaseButton({super.key});

  @override
  _RestorePurchaseButtonState createState() => _RestorePurchaseButtonState();
}

class _RestorePurchaseButtonState extends State<RestorePurchaseButton> {
  bool restored = false;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      child: Text(
        context.loc.purchaseScreenRestore,
        style: Theme.of(context).textTheme.bodyText2,
      ),
      onPressed: restored ? null : _restore,
    );
  }

  Future<void> _restore() async {
    setState(() {
      restored = true;
    });

    var config = context.read<AppConfig>();
    config.addListener(_configListener);

    Log.i("Restoring Purchases");
    GitJournalInAppPurchases.restorePurchases();
  }

  void _configListener() {
    if (!mounted) return;

    var config = context.read<AppConfig>();
    if (config.proMode) {
      Log.i("Restored Purchases");
      Navigator.of(context).pop();
    }
  }
}
