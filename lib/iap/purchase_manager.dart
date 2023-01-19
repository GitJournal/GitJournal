/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:async';

import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/iap/iap.dart';
import 'package:gitjournal/iap/purchase_slider.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/settings/app_config.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

// ignore_for_file: cancel_subscriptions

typedef PurchaseCallback = void Function(String, SubscriptionStatus?);

class PurchaseManager {
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  final List<PurchaseCallback> _callbacks = [];

  static String? error;
  static PurchaseManager? _instance;

  static Future<PurchaseManager?> init() async {
    if (_instance != null) {
      return _instance;
    }

    _instance = PurchaseManager();

    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      error = "Store cannot be reached";
      _instance = null;
      return null;
    }

    // Start listening for changes
    _instance!._subscription = InAppPurchase.instance.purchaseStream.listen(
      _instance!._listenToPurchaseUpdated,
    );

    return _instance;
  }

  void destroy() {
    _instance?._subscription.cancel();
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetails) async {
    for (var pd in purchaseDetails) {
      await _handlePurchaseUpdate(pd);
    }
  }

  Future<void> _handlePurchaseUpdate(PurchaseDetails purchaseDetails) async {
    Log.i(
        "PurchaseDetailsUpdated: {productID: ${purchaseDetails.productID}, purchaseID: ${purchaseDetails.purchaseID}, status: ${purchaseDetails.status}");

    switch (purchaseDetails.status) {
      case PurchaseStatus.pending:
        Log.i("Pending - ${purchaseDetails.productID}");
        break;

      case PurchaseStatus.error:
        _handleIAPError(purchaseDetails.error!);
        break;

      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        Log.i("Verifying purchase sub");
        try {
          var subStatus = await verifyPurchase(purchaseDetails);
          if (subStatus.isActive) {
            _deliverProduct(subStatus);
          } else {
            // FIXME: This should be translated!
            _handleError("Purchase Failed");
            return;
          }
        } catch (err) {
          _handleError(err.toString());
        }
        break;

      case PurchaseStatus.canceled:
        _handleError("Purchase Canceled");
        break;
    }

    if (purchaseDetails.pendingCompletePurchase) {
      Log.i("Pending Complete Purchase - ${purchaseDetails.productID}");

      try {
        await InAppPurchase.instance.completePurchase(purchaseDetails);
      } catch (e, stackTrace) {
        logException(e, stackTrace);
      }
    }
  }

  void _handleIAPError(IAPError err) {
    var msg = "${err.code} - ${err.message} - ${err.details}";
    Log.e(msg);

    _handleError(msg);
  }

  void _handleError(String err) {
    Log.e(err);

    Log.i("Calling Purchase Error Callbacks: ${_callbacks.length}");
    for (var callback in _callbacks) {
      callback(err, null);
    }
  }

  void _deliverProduct(SubscriptionStatus status) {
    var appConfig = AppConfig.instance;
    appConfig.proMode = true;
    appConfig.save();

    Log.i("Calling Purchase Completed Callbacks: ${_callbacks.length}");
    for (var callback in _callbacks) {
      callback("", status);
    }

    // FIXME: We need to restart the app?
  }

  /// Returns the ProductDetails sorted by price
  Future<ProductDetailsResponse> queryProductDetails(Set<String> skus) async {
    // Cache this response?
    // FIXME: What if the sotre cannot be reached?
    var response = await InAppPurchase.instance.queryProductDetails(skus);
    response.productDetails.sort((a, b) {
      var pa = PaymentInfo.fromProductDetail(a);
      var pb = PaymentInfo.fromProductDetail(b);
      return pa.value.compareTo(pb.value);
    });

    return response;
  }

  Future<bool> buyNonConsumable(
    ProductDetails product,
    PurchaseCallback callback,
  ) async {
    var purchaseParam = PurchaseParam(productDetails: product);
    var sentSuccess = await InAppPurchase.instance
        .buyNonConsumable(purchaseParam: purchaseParam);

    if (sentSuccess) {
      _callbacks.add(callback);
    }
    return sentSuccess;
  }
}
