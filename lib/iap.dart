import 'package:gitjournal/utils/logger.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:gitjournal/settings.dart';
import 'package:gitjournal/.env.dart';

class InAppPurchases {
  static void confirmProPurchase() async {
    // FIXME: Only check this if pro mode is expired

    //Purchases.setDebugLogsEnabled(true);
    await Purchases.setup(environment['revenueCat']);

    PurchaserInfo purchaserInfo = await Purchases.getPurchaserInfo();
    print("Got PurchaserInfo $purchaserInfo");
    var isPro = purchaserInfo.entitlements.active.containsKey("pro");
    print("IsPro $isPro");

    if (Settings.instance.proMode != isPro) {
      Log.i("Pro mode changed to $isPro");
      Settings.instance.proMode = isPro;
      Settings.instance.save();
    }
  }
}
