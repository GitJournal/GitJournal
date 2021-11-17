/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:convert';

import 'package:flutter/foundation.dart' as foundation;

import 'package:google_api_availability/google_api_availability.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase/store_kit_wrappers.dart';
import 'package:universal_io/io.dart' show Platform;

import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/features.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/settings/app_config.dart';

class InAppPurchases {
  static Future<void> confirmProPurchaseBoot() async {
    clearTransactionsIos();
    confirmPendingPurchases();

    if (Features.alwaysPro || !AppConfig.instance.validateProMode) {
      return;
    }

    if (AppConfig.instance.proMode == false) {
      Log.i("confirmProPurchaseBoot: Pro Mode is false");
      return;
    }

    var currentDt = DateTime.now().toUtc().toIso8601String();
    var exp = AppConfig.instance.proExpirationDate;

    Log.i("Checking if ProMode should be enabled. Exp: $exp");
    if (exp.isNotEmpty && exp.compareTo(currentDt) > 0) {
      Log.i("Not checking PurchaseInfo as exp = $exp and cur = $currentDt");
      return;
    }

    if (foundation.kDebugMode) {
      Log.d("Ignoring IAP pro check - debug mode");
      return;
    }

    return confirmProPurchase();
  }

  static Future<void> confirmProPurchase() async {
    SubscriptionStatus sub;

    Log.i("Trying to confirmProPurchase");
    try {
      sub = await _subscriptionStatus();
    } catch (e, stackTrace) {
      Log.e("Failed to get subscription status", ex: e, stacktrace: stackTrace);
      Log.i("Disabling Pro mode as it has probably expired");

      AppConfig.instance.proMode = false;
      AppConfig.instance.proExpirationDate = "";
      AppConfig.instance.save();

      return;
    }

    Log.i("SubscriptionState: $sub");

    var isPro = sub.isPro;
    var expiryDate = sub.expiryDate.toIso8601String();
    Log.i("Pro ExpiryDate: $expiryDate");

    if (AppConfig.instance.proMode != isPro) {
      Log.i("Pro mode changed to $isPro");
      AppConfig.instance.proMode = isPro;
      AppConfig.instance.proExpirationDate = expiryDate;
      AppConfig.instance.save();
    } else {
      AppConfig.instance.proExpirationDate = expiryDate;
      AppConfig.instance.save();
    }
  }

  static Future<SubscriptionStatus> _subscriptionStatus() async {
    InAppPurchaseConnection.enablePendingPurchases();
    var iapConn = InAppPurchaseConnection.instance;
    var dtNow = DateTime.now().toUtc();

    var response = await iapConn.queryPastPurchases();
    Log.i("Number of Past Purchases: ${response.pastPurchases.length}");

    var subs = <SubscriptionStatus>[];
    for (var purchase in response.pastPurchases) {
      DateTime? dt;
      try {
        dt = await getExpiryDate(
            purchase.verificationData.serverVerificationData,
            purchase.productID,
            _isPurchase(purchase));
      } catch (e) {
        // Ignore
      }

      if (dt == null || !dt.isAfter(dtNow)) {
        continue;
      }

      var sub = SubscriptionStatus(true, dt);
      Log.i("--> $sub");
      subs.add(sub);
    }
    Log.i("Number of SubscriptionStatus: ${subs.length}");

    var sub = SubscriptionStatus(false, dtNow);
    for (var s in subs) {
      if (s.expiryDate.isAfter(sub.expiryDate)) {
        sub = s;
      }
    }

    return sub;
  }

  static Future<void> clearTransactionsIos() async {
    if (!Platform.isIOS) {
      return;
    }

    final transactions = await SKPaymentQueueWrapper().transactions();
    Log.i("Old Transactions: ${transactions.length}");
    for (final transaction in transactions) {
      Log.i("Processing old transaction: $transaction");
      try {
        if (transaction.transactionState ==
            SKPaymentTransactionStateWrapper.purchased) {
          Log.i("Already purchased. Ignoring");
          continue;
        }
        if (transaction.transactionState ==
            SKPaymentTransactionStateWrapper.restored) {
          Log.i("Already Restored. Ignoring");
          continue;
        }

        if (transaction.transactionState !=
            SKPaymentTransactionStateWrapper.purchasing) {
          Log.i("Purchasing. Finishing Transaction.");

          await SKPaymentQueueWrapper().finishTransaction(transaction);
        }
      } catch (e, stackTrace) {
        logException(e, stackTrace);
      }
    }
  }

  static Future<void> confirmPendingPurchases() async {
    // On iOS this results in a "Sign in with Apple ID" dialog
    if (!Platform.isAndroid) {
      return;
    }

    var availability = await GoogleApiAvailability.instance
        .checkGooglePlayServicesAvailability();
    if (availability != GooglePlayServicesAvailability.success) {
      Log.e("Google Play Services Not Available");
      return;
    }

    InAppPurchaseConnection.enablePendingPurchases();
    final iapCon = InAppPurchaseConnection.instance;

    var pastPurchases = await iapCon.queryPastPurchases();
    for (var pd in pastPurchases.pastPurchases) {
      if (pd.pendingCompletePurchase) {
        Log.i("Pending Complete Purchase - ${pd.productID}");

        try {
          var _ = await iapCon.completePurchase(pd);
        } catch (e, stackTrace) {
          logException(e, stackTrace);
        }
      }
    }
  }
}

const base_url = 'https://us-central1-gitjournal-io.cloudfunctions.net';
const ios_url = '$base_url/IAPIosVerify';
const android_url = '$base_url/IAPAndroidVerify';

Future<DateTime?> getExpiryDate(
    String receipt, String sku, bool isPurchase) async {
  assert(receipt.isNotEmpty);

  var body = {
    'receipt': receipt,
    "sku": sku,
    'pseudoId': '',
    'is_purchase': isPurchase,
  };
  Log.i("getExpiryDate ${json.encode(body)}");

  var url = Uri.parse(Platform.isIOS ? ios_url : android_url);
  var response = await http.post(url, body: json.encode(body));
  if (response.statusCode != 200) {
    Log.e("Received Invalid Status Code from GCP IAP Verify", props: {
      "code": response.statusCode,
      "body": response.body,
    });
    throw IAPVerifyException(
      code: response.statusCode,
      body: response.body,
      receipt: receipt,
      sku: sku,
      isPurchase: isPurchase,
    );
  }

  Log.i("IAP Verify body: ${response.body}");

  var b = json.decode(response.body) as Map?;
  if (b == null || !b.containsKey("expiry_date")) {
    Log.e("Received Invalid Body from GCP IAP Verify", props: {
      "code": response.statusCode,
      "body": response.body,
    });
    return null;
  }

  var expiryDateMs = b['expiry_date'] as int;
  return DateTime.fromMillisecondsSinceEpoch(expiryDateMs, isUtc: true);
}

class SubscriptionStatus {
  final bool isPro;
  final DateTime expiryDate;

  SubscriptionStatus(this.isPro, this.expiryDate);

  @override
  String toString() =>
      "SubscriptionStatus{isPro: $isPro, expiryDate: $expiryDate}";
}

Future<SubscriptionStatus> verifyPurchase(PurchaseDetails purchase) async {
  var dt = await getExpiryDate(
    purchase.verificationData.serverVerificationData,
    purchase.productID,
    _isPurchase(purchase),
  );
  if (dt == null || !dt.isAfter(DateTime.now())) {
    return SubscriptionStatus(false, dt!);
  }
  return SubscriptionStatus(true, dt);
}

// Checks if it is a subscription or a purchase
bool _isPurchase(PurchaseDetails purchase) {
  var sku = purchase.productID;
  return !sku.contains('monthly') && !sku.contains('_sub_');
}

class IAPVerifyException implements Exception {
  final int code;
  final String body;
  final String receipt;
  final String sku;
  final bool isPurchase;

  IAPVerifyException({
    required this.code,
    required this.body,
    required this.receipt,
    required this.sku,
    required this.isPurchase,
  });

  @override
  String toString() {
    return "IAPVerifyException{code: $code, body: $body, receipt: $receipt, $sku: sku, isPurchase: $isPurchase}";
  }
}
