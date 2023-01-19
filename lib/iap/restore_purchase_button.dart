/*
 * SPDX-FileCopyrightText: 2019-2022 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:gitjournal/iap/iap.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/utils/utils.dart';

class RestorePurchaseButton extends StatefulWidget {
  const RestorePurchaseButton({super.key});

  @override
  _RestorePurchaseButtonState createState() => _RestorePurchaseButtonState();
}

class _RestorePurchaseButtonState extends State<RestorePurchaseButton> {
  bool computing = false;

  @override
  Widget build(BuildContext context) {
    var text = computing ? '...' : context.loc.purchaseScreenRestore;

    return OutlinedButton(
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyText2,
      ),
      onPressed: () async {
        setState(() {
          computing = true;
        });
        Log.i("Restoring Purchases");
        var result = await InAppPurchases.confirmProPurchase();
        if (result.isFailure) {
          Log.e("confirmProPurchase", result: result);
          var err = result.error ?? Exception("Unknown Error");
          showErrorMessageSnackbar(context, err.toString());

          setState(() {
            computing = false;
          });
          return;
        }

        var sub = result.getOrThrow();
        if (sub.isActive) {
          Navigator.of(context).pop();
        } else {
          var expDate = sub.expiryDate != null
              ? sub.expiryDate!.toIso8601String().substring(0, 10)
              : context.loc.purchaseScreenUnknown;
          var meesage = context.loc.purchaseScreenExpired(expDate);
          showSnackbar(context, meesage);

          setState(() {
            computing = false;
          });
        }
      },
    );
  }
}
