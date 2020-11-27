import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:gitjournal/app_settings.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/iap.dart';
import 'package:gitjournal/utils/logger.dart';

enum PurchaseError {
  StoreCannotBeReached,
}

// ignore_for_file: cancel_subscriptions

typedef PurchaseCallback = void Function(PurchaseError, SubscriptionStatus);

class PurchaseManager {
  InAppPurchaseConnection con;
  StreamSubscription<List<PurchaseDetails>> _subscription;
  List<PurchaseCallback> _callbacks = [];

  static PurchaseError error;
  static PurchaseManager _instance;

  static Future<PurchaseManager> init() async {
    if (_instance != null) {
      return _instance;
    }

    _instance = PurchaseManager();

    InAppPurchaseConnection.enablePendingPurchases();
    _instance.con = InAppPurchaseConnection.instance;

    final bool available = await _instance.con.isAvailable();
    if (!available) {
      error = PurchaseError.StoreCannotBeReached;
      _instance = null;
      return null;
    }

    // Start listening for changes
    var i = _instance;
    final purchaseUpdates = i.con.purchaseUpdatedStream;
    i._subscription = purchaseUpdates.listen(i._listenToPurchaseUpdated);

    return _instance;
  }

  void destroy() {
    _instance._subscription.cancel();
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetails) async {
    for (var pd in purchaseDetails) {
      await _handlePurchaseUpdate(pd);
    }
  }

  Future<void> _handlePurchaseUpdate(PurchaseDetails purchaseDetails) async {
    Log.i(
        "PurchaseDetailsUpdated: {productID: ${purchaseDetails.productID}, purchaseID: ${purchaseDetails.purchaseID}, status: ${purchaseDetails.status}");

    if (purchaseDetails.status == PurchaseStatus.pending) {
      Log.i("Pending - ${purchaseDetails.productID}");
      return;
    }

    if (purchaseDetails.status == PurchaseStatus.error) {
      _handleIAPError(purchaseDetails.error);
      return;
    } else if (purchaseDetails.status == PurchaseStatus.purchased) {
      Log.i("Verifying purchase sub");
      try {
        var subStatus = await verifyPurchase(purchaseDetails);
        if (subStatus.isPro) {
          _deliverProduct(subStatus);
        } else {
          _handleError(tr('widgets.PurchaseWidget.failed'));
          return;
        }
      } catch (err) {
        _handleError(err.toString());
      }
    }
    if (purchaseDetails.pendingCompletePurchase) {
      Log.i("Pending Complete Purchase - ${purchaseDetails.productID}");

      try {
        await InAppPurchaseConnection.instance
            .completePurchase(purchaseDetails);
      } catch (e, stackTrace) {
        logException(e, stackTrace);
      }
    }
  }

  void _handleIAPError(IAPError err) {
    var msg = "${err.code} - ${err.message} - ${err.details}";
    Log.e(msg);
  }

  void _handleError(String err) {
    Log.e(err);
  }

  void _deliverProduct(SubscriptionStatus status) {
    var appSettings = AppSettings.instance;
    appSettings.proMode = status.isPro;
    appSettings.proExpirationDate = status.expiryDate.toIso8601String();
    appSettings.save();

    for (var callback in _callbacks) {
      callback(null, status);
    }
  }

  Future<ProductDetailsResponse> queryProductDetails(Set<String> skus) async {
    // Cache this response?
    final response = await _instance.con.queryProductDetails(skus);
    return response;
  }

  Future<bool> buyNonConsumable(
    ProductDetails product,
    PurchaseCallback callback,
  ) async {
    var purchaseParam = PurchaseParam(productDetails: product);
    var sentSuccess = await InAppPurchaseConnection.instance
        .buyNonConsumable(purchaseParam: purchaseParam);

    if (sentSuccess) {
      _callbacks.add(callback);
    }
    return sentSuccess;
  }
}
