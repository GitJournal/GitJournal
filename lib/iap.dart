import 'dart:convert';
import 'dart:io' show Platform;

import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase/store_kit_wrappers.dart';
import 'package:meta/meta.dart';

import 'package:gitjournal/app.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/features.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/utils/logger.dart';

class InAppPurchases {
  static Future<void> confirmProPurchaseBoot() async {
    clearTransactionsIos();

    if (Features.alwaysPro) {
      return;
    }

    if (Settings.instance.proMode == false) {
      Log.i("confirmProPurchaseBoot: Pro Mode is false");
      return;
    }

    var currentDt = DateTime.now().toUtc().toIso8601String();
    var exp = Settings.instance.proExpirationDate;

    Log.i("Checking if ProMode should be enabled. Exp: $exp");
    if (exp != null && exp.isNotEmpty && exp.compareTo(currentDt) > 0) {
      Log.i("Not checking PurchaseInfo as exp = $exp and cur = $currentDt");
      return;
    }

    if (JournalApp.isInDebugMode) {
      Log.d("Ignoring IAP pro check - debug mode");
      return;
    }

    return confirmProPurchase();
  }

  static Future<void> confirmProPurchase() async {
    SubscriptionStatus sub;

    try {
      sub = await _subscriptionStatus();
      if (sub == null) {
        Log.i("Failed to get subscription status");
        return;
      }
    } catch (e, stackTrace) {
      Log.e("Failed to get subscription status", ex: e, stacktrace: stackTrace);
      Log.i("Disabling Pro mode as it has probably expired");

      Settings.instance.proMode = false;
      Settings.instance.proExpirationDate = "";
      Settings.instance.save();

      return;
    }

    var isPro = sub.isPro;
    var expiryDate = sub.expiryDate.toIso8601String();
    Log.i(sub.toString());

    if (Settings.instance.proMode != isPro) {
      Log.i("Pro mode changed to $isPro");
      Settings.instance.proMode = isPro;
      Settings.instance.proExpirationDate = expiryDate;
      Settings.instance.save();
    } else {
      Settings.instance.proExpirationDate = expiryDate;
      Settings.instance.save();
    }
  }

  static Future<SubscriptionStatus> _subscriptionStatus() async {
    InAppPurchaseConnection.enablePendingPurchases();
    var iapConn = InAppPurchaseConnection.instance;
    var dtNow = DateTime.now().toUtc();

    var response = await iapConn.queryPastPurchases();
    for (var purchase in response.pastPurchases) {
      DateTime dt;
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
      return SubscriptionStatus(true, dt);
    }
    return SubscriptionStatus(false, dtNow);
  }

  static Future<void> clearTransactionsIos() async {
    if (Platform.isIOS) {
      final transactions = await SKPaymentQueueWrapper().transactions();
      for (final transaction in transactions) {
        try {
          if (transaction.transactionState ==
              SKPaymentTransactionStateWrapper.purchased) {
            continue;
          }
          if (transaction.transactionState ==
              SKPaymentTransactionStateWrapper.restored) {
            continue;
          }

          if (transaction.transactionState !=
              SKPaymentTransactionStateWrapper.purchasing) {
            await SKPaymentQueueWrapper().finishTransaction(transaction);
          }
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

Future<DateTime> getExpiryDate(
    String receipt, String sku, bool isPurchase) async {
  assert(receipt.isNotEmpty);

  var body = {
    'receipt': receipt,
    "sku": sku,
    'pseudoId': Settings.instance.pseudoId,
    'is_purchase': isPurchase,
  };
  Log.i("getExpiryDate ${json.encode(body)}");

  var url = Platform.isIOS ? ios_url : android_url;
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

  var b = json.decode(response.body) as Map;
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
    return SubscriptionStatus(false, dt);
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
    @required this.code,
    @required this.body,
    @required this.receipt,
    @required this.sku,
    @required this.isPurchase,
  });

  @override
  String toString() {
    return "IAPVerifyException{code: $code, body: $body, receipt: $receipt, $sku: sku, isPurchase: $isPurchase}";
  }
}
