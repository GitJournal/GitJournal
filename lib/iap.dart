import 'dart:io' show Platform;

import 'package:gitjournal/app.dart';
import 'package:gitjournal/utils/logger.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:gitjournal/settings.dart';

class InAppPurchases {
  static void confirmProPurchase() async {
    var currentDt = DateTime.now().toUtc().toIso8601String();
    var exp = Settings.instance.proExpirationDate;
    if (exp != null && exp.isNotEmpty && exp.compareTo(currentDt) > 0) {
      Log.i("Not checking PurchaseInfo as exp = $exp and cur = $currentDt");
      return;
    }
    if (exp == "-") {
      Log.d("Ignoring IAP pro check - already checked");
      return;
    }

    if (JournalApp.isInDebugMode) {
      Log.d("Ignoring IAP pro check - debug mode");
      return;
    }

    var sub = await _subscriptionStatus();
    var isPro = sub == null ? false : sub.isPro;
    Log.i("IsPro $isPro");

    if (Settings.instance.proMode != isPro) {
      Log.i("Pro mode changed to $isPro");
      Settings.instance.proMode = isPro;
      Settings.instance.save();
    } else {
      Settings.instance.proExpirationDate =
          sub != null ? sub.expiryDate.toIso8601String() : "-";
      Settings.instance.save();
    }
  }

  static Future<SubscriptionStatus> _subscriptionStatus() async {
    InAppPurchaseConnection.enablePendingPurchases();
    var iapConn = InAppPurchaseConnection.instance;

    if (Platform.isIOS) {
      //var history = await iapConn.refreshPurchaseVerificationData();
    } else if (Platform.isAndroid) {
      var response = await iapConn.queryPastPurchases();
      if (response.pastPurchases.isEmpty) {
        return null;
      }

      for (var purchase in response.pastPurchases) {
        var dt = DateTime.fromMillisecondsSinceEpoch(
            int.parse(purchase.transactionDate));
        return SubscriptionStatus(true, dt.add(const Duration(days: 31)));
      }
    }

    return null;
    /*
    for (var purchase in response.pastPurchases) {
      var difference =
        DateTime.now().difference(purchase.transactionDate);
      print(purchase);
      print(purchase.productID);
      print(purchase.purchaseID);
      print(purchase.transactionDate);
      print(purchase.verificationData);
      print(purchase.verificationData.localVerificationData);
      print(purchase.verificationData.serverVerificationData);
      print(purchase.verificationData.source);

      InAppPurchaseConnection.instance.
    }
    */
  }
}

class SubscriptionStatus {
  final bool isPro;
  final DateTime expiryDate;

  SubscriptionStatus(this.isPro, this.expiryDate);
}
