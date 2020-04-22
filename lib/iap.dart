import 'package:gitjournal/utils/logger.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:gitjournal/settings.dart';
import 'package:gitjournal/.env.dart';

class InAppPurchases {
  static void confirmProPurchase() async {
    var currentDt = DateTime.now().toUtc().toIso8601String();
    var exp = Settings.instance.proExpirationDate;
    if (exp.isNotEmpty && exp.compareTo(currentDt) > 0) {
      print("Not checking PurchaseInfo as exp = $exp and cur = $currentDt");
      return;
    }

    Purchases.setDebugLogsEnabled(false);
    await Purchases.setup(
      environment['revenueCat'],
      appUserId: Settings.instance.pseudoId,
    );

    PurchaserInfo purchaserInfo = await Purchases.getPurchaserInfo();
    print("Got PurchaserInfo $purchaserInfo");
    var isPro = purchaserInfo.entitlements.active.containsKey("pro");
    print("IsPro $isPro");

    if (Settings.instance.proMode != isPro) {
      Log.i("Pro mode changed to $isPro");
      Settings.instance.proMode = isPro;
      Settings.instance.save();
    } else {
      Settings.instance.proExpirationDate = purchaserInfo.latestExpirationDate;
      Settings.instance.save();
    }
  }
}
