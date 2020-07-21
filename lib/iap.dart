import 'dart:convert';
import 'dart:io' show Platform;

import 'package:gitjournal/app.dart';
import 'package:gitjournal/utils/logger.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:http/http.dart' as http;

import 'package:gitjournal/settings.dart';

class InAppPurchases {
  static Future<void> confirmProPurchaseBoot() async {
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
    var sub = await _subscriptionStatus();
    if (sub == null) {
      Log.i("Failed to get subscription status");
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

    if (Platform.isIOS) {
      var verificationData = await iapConn.refreshPurchaseVerificationData();
      var dt = await getExpiryDate(verificationData.serverVerificationData, "");
      var isPro = dt != null ? dt.isAfter(DateTime.now()) : false;

      return SubscriptionStatus(isPro, dt);
    } else if (Platform.isAndroid) {
      var response = await iapConn.queryPastPurchases();
      for (var purchase in response.pastPurchases) {
        var dt = await getExpiryDate(
            purchase.verificationData.serverVerificationData,
            purchase.productID);
        if (dt == null || !dt.isAfter(DateTime.now())) {
          continue;
        }
        return SubscriptionStatus(true, dt);
      }
      return SubscriptionStatus(false, DateTime.now().toUtc());
    }

    return null;
  }
}

const base_url = 'https://us-central1-gitjournal-io.cloudfunctions.net';
const ios_url = '$base_url/IAPIosVerify';
const android_url = '$base_url/IAPAndroidVerify';

Future<DateTime> getExpiryDate(String receipt, String sku) async {
  assert(receipt.isNotEmpty);

  var body = {
    'receipt': receipt,
    "sku": sku,
  };
  Log.i("getExpiryDate ${json.encode(body)}");

  var url = Platform.isIOS ? ios_url : android_url;
  var response = await http.post(url, body: json.encode(body));
  if (response.statusCode != 200) {
    Log.e("Received Invalid Status Code from GCP IAP Verify", props: {
      "code": response.statusCode,
      "body": response.body,
    });
    return null;
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
  return DateTime.fromMillisecondsSinceEpoch(expiryDateMs);
}

class SubscriptionStatus {
  final bool isPro;
  final DateTime expiryDate;

  SubscriptionStatus(this.isPro, this.expiryDate);

  @override
  String toString() =>
      "SubscriptionStatus{isPro: $isPro, expiryDate: $expiryDate}";
}
