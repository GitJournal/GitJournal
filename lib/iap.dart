import 'package:gitjournal/app.dart';
import 'package:gitjournal/utils/logger.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:gitjournal/settings.dart';
import 'package:gitjournal/.env.dart';

class InAppPurchases {
  static void confirmProPurchase() async {
    var currentDt = DateTime.now().toUtc().toIso8601String();
    var exp = Settings.instance.proExpirationDate;
    if (exp != null && exp.isNotEmpty && exp.compareTo(currentDt) > 0) {
      Log.i("Not checking PurchaseInfo as exp = $exp and cur = $currentDt");
      return;
    }

    if (JournalApp.isInDebugMode) {
      return;
    }

    await Purchases.setup(
      environment['revenueCat'],
      appUserId: Settings.instance.pseudoId,
    );

    PurchaserInfo purchaserInfo = await Purchases.getPurchaserInfo();
    Log.i("Got PurchaserInfo $purchaserInfo");
    var isPro = purchaserInfo.entitlements.active.containsKey("pro");
    Log.i("IsPro $isPro");

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
