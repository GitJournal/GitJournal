/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:function_types/function_types.dart';
import 'package:gitjournal/analytics/analytics.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/iap/iap.dart';
import 'package:gitjournal/iap/purchase_manager.dart';
import 'package:gitjournal/iap/purchase_slider.dart';
import 'package:gitjournal/iap/purchase_thankyou_screen.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseButton extends StatelessWidget {
  final ProductDetails? product;
  final String timePeriod;
  final bool subscription;
  final Func1<bool, void> purchaseStarted;
  final PurchaseCallback purchaseCompleted;

  const PurchaseButton(
    this.product,
    this.timePeriod, {
    super.key,
    required this.subscription,
    required this.purchaseStarted,
    required this.purchaseCompleted,
  });

  @override
  Widget build(BuildContext context) {
    String text;
    if (product != null) {
      text = context.loc.widgetsPurchaseButtonText(product!.price);
      if (subscription) {
        text += '/ $timePeriod';
      }
    } else {
      text = context.loc.widgetsPurchaseButtonFail;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(32.0, 16.0, 32.0, 16.0),
      child: ElevatedButton(
        onPressed: product != null ? () => _reportExceptions(context) : null,
        style: ButtonStyle(
          backgroundColor:
              WidgetStateProperty.all<Color>(Theme.of(context).primaryColor),
        ),
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }

  Future<void> _initPurchase(BuildContext context) async {
    var pm = await PurchaseManager.init();
    if (pm == null) {
      purchaseCompleted(PurchaseManager.error!, null);
      return;
    }

    var sentSuccess = await pm.buyNonConsumable(product!, purchaseCompleted);
    purchaseStarted(sentSuccess);

    /*
    if (!sentSuccess) {
      var dialog = PurchaseFailedDialog(context.loc.widgets.PurchaseButton.failSend);
      await showDialog(context: context, builder: (context) => dialog);
      return;
    }
    */
  }

  Future<void> _reportExceptions(BuildContext context) async {
    try {
      await _initPurchase(context);
    } catch (err, stackTrace) {
      logException(err, stackTrace);

      var errStr =
          context.loc.widgetsPurchaseButtonFailPurchase(err.toString());
      await showDialog(
        context: context,
        builder: (context) => PurchaseFailedDialog(errStr),
      );
    }
  }
}

class PurchaseWidget extends StatefulWidget {
  final Set<String> skus;
  final String defaultSku;
  final String timePeriod;
  final bool isSubscription;

  const PurchaseWidget({
    super.key,
    required this.skus,
    required this.defaultSku,
    this.timePeriod = "",
    required this.isSubscription,
  });

  @override
  _PurchaseWidgetState createState() => _PurchaseWidgetState();
}

class _PurchaseWidgetState extends State<PurchaseWidget> {
  List<ProductDetails>? _products;
  ProductDetails? _selectedProduct;

  String error = "";
  bool _pendingPurchase = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    var pm = await PurchaseManager.init();
    if (pm == null) {
      setState(() {
        error = PurchaseManager.error!;
      });
    }

    final response = await pm!.queryProductDetails(widget.skus);
    if (response.error != null) {
      Log.e("IAP queryProductDetails: ${response.error}");
    }

    if (!mounted) return;

    var products = response.productDetails;
    /*
    Log.i("Products: ${products.length}");
    for (var p in products) {
      Log.i("Product ${p.id} -> ${p.price}");
    }
    */

    setState(() {
      _products = products;
      _selectedProduct = _products!.isNotEmpty ? _products!.first : null;

      if (_products!.length > 1) {
        for (var p in _products!) {
          if (p.id == widget.defaultSku) {
            _selectedProduct = p;
            break;
          }
        }
      } else {
        // FIXME: Add a fake product for development
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (error.isNotEmpty) {
      return Text("Failed to load: $error");
    }
    if (_pendingPurchase) {
      return const CircularProgressIndicator();
    }
    return _products == null
        ? const CircularProgressIndicator()
        : buildBody(context);
  }

  ProductDetails? _fromPaymentInfo(PaymentInfo info) {
    for (var p in _products!) {
      if (p.id == info.id) {
        return p;
      }
    }
    assert(false);
    return null;
  }

  Widget buildBody(BuildContext context) {
    if (_products == null || _products!.isEmpty) {
      return const Icon(Icons.error, size: 64);
    }

    var slider = PurchaseSlider(
      values: _products!.map(PaymentInfo.fromProductDetail).toList(),
      selectedValue: PaymentInfo.fromProductDetail(_selectedProduct!),
      onChanged: (PaymentInfo info) {
        setState(() {
          _selectedProduct = _fromPaymentInfo(info);
        });
      },
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _PurchaseSliderButton(
              icon: const Icon(Icons.arrow_left),
              onPressed: () {
                setState(() {
                  _selectedProduct = _prevProduct();
                });
              },
            ),
            Expanded(child: slider),
            _PurchaseSliderButton(
              icon: const Icon(Icons.arrow_right),
              onPressed: () {
                setState(() {
                  _selectedProduct = _nextProduct();
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 32.0),
        PurchaseButton(
          _selectedProduct,
          widget.timePeriod,
          subscription: widget.isSubscription,
          purchaseStarted: (bool started) {
            setState(() {
              _pendingPurchase = started;
            });
          },
          purchaseCompleted: _purchaseCompleted,
        ),
      ],
    );
  }

  ProductDetails? _prevProduct() {
    for (var i = 0; i < _products!.length; i++) {
      if (_products![i] == _selectedProduct) {
        return i > 0 ? _products![i - 1] : _products![i];
      }
    }

    return null;
  }

  ProductDetails? _nextProduct() {
    for (var i = 0; i < _products!.length; i++) {
      if (_products![i] == _selectedProduct) {
        return i < _products!.length - 1 ? _products![i + 1] : _products![i];
      }
    }

    return null;
  }

  void _purchaseCompleted(String err, SubscriptionStatus? subStatus) {
    if (!mounted) return;

    if (err.isEmpty) {
      Log.i("Purchase Completed: $subStatus");
      logEvent(Event.PurchaseScreenThankYou);
      Navigator.of(context).popAndPushNamed(PurchaseThankYouScreen.routePath);
      return;
    }

    if (err.toLowerCase().contains("usercanceled")) {
      setState(() {
        _pendingPurchase = false;
      });
      Log.e(err);
      return;
    }
    showDialog(
      context: context,
      builder: (context) => PurchaseFailedDialog(err),
    );
  }
}

class _PurchaseSliderButton extends StatelessWidget {
  final Widget icon;
  final void Function() onPressed;

  const _PurchaseSliderButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: icon,
      padding: const EdgeInsets.all(0.0),
      iconSize: 64.0,
      onPressed: onPressed,
    );
  }
}

class PurchaseFailedDialog extends StatelessWidget {
  final String text;

  const PurchaseFailedDialog(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.loc.widgetsPurchaseWidgetFailed),
      content: Text(text),
      actions: <Widget>[
        TextButton(
          child: Text(context.loc.settingsOk),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
