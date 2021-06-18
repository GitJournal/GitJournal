import 'dart:async';

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:function_types/function_types.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:gitjournal/analytics/analytics.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/iap/iap.dart';
import 'package:gitjournal/iap/purchase_manager.dart';
import 'package:gitjournal/iap/purchase_slider.dart';
import 'package:gitjournal/settings/app_settings.dart';
import 'package:gitjournal/utils/logger.dart';

class PurchaseButton extends StatelessWidget {
  final ProductDetails? product;
  final String timePeriod;
  final bool subscription;
  final Func1<bool, void> purchaseStarted;
  final PurchaseCallback purchaseCompleted;

  PurchaseButton(
    this.product,
    this.timePeriod, {
    required this.subscription,
    required this.purchaseStarted,
    required this.purchaseCompleted,
  });

  @override
  Widget build(BuildContext context) {
    String text;
    if (product != null) {
      text = tr("widgets.PurchaseButton.text", namedArgs: {
        'price': product!.price,
      });
      if (subscription) {
        text += '/ $timePeriod';
      }
    } else {
      text = tr("widgets.PurchaseButton.fail");
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(32.0, 16.0, 32.0, 16.0),
      child: ElevatedButton(
        child: Text(text, textAlign: TextAlign.center),
        onPressed: product != null ? () => _reportExceptions(context) : null,
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
        ),
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
      var dialog = PurchaseFailedDialog(tr("widgets.PurchaseButton.failSend"));
      await showDialog(context: context, builder: (context) => dialog);
      return;
    }
    */
  }

  void _reportExceptions(BuildContext context) async {
    try {
      await _initPurchase(context);
    } catch (err, stackTrace) {
      logException(err, stackTrace);

      var errStr = tr(
        "widgets.PurchaseButton.failPurchase",
        args: [err.toString()],
      );
      var dialog = PurchaseFailedDialog(errStr);
      await showDialog(context: context, builder: (context) => dialog);
    }
  }
}

class PurchaseWidget extends StatefulWidget {
  final Set<String> skus;
  final String defaultSku;
  final String timePeriod;
  final bool isSubscription;

  PurchaseWidget({
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
      children: <Widget>[
        Row(
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
          mainAxisSize: MainAxisSize.max,
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
      mainAxisAlignment: MainAxisAlignment.spaceAround,
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
      Navigator.of(context).popAndPushNamed('/purchase_thank_you');
      return;
    }

    if (err.toLowerCase().contains("usercanceled")) {
      setState(() {
        _pendingPurchase = false;
      });
      Log.e(err);
      return;
    }
    var dialog = PurchaseFailedDialog(err);
    showDialog(context: context, builder: (context) => dialog);
  }
}

class _PurchaseSliderButton extends StatelessWidget {
  final Widget icon;
  final void Function() onPressed;

  _PurchaseSliderButton({required this.icon, required this.onPressed});

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

  PurchaseFailedDialog(this.text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(tr('widgets.PurchaseWidget.failed')),
      content: Text(text),
      actions: <Widget>[
        TextButton(
          child: Text(tr('settings.ok')),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class RestorePurchaseButton extends StatefulWidget {
  @override
  _RestorePurchaseButtonState createState() => _RestorePurchaseButtonState();
}

class _RestorePurchaseButtonState extends State<RestorePurchaseButton> {
  bool computing = false;

  @override
  Widget build(BuildContext context) {
    var text = computing ? '...' : tr('purchase_screen.restore');

    return OutlinedButton(
      child: Text(text),
      onPressed: () async {
        setState(() {
          computing = true;
        });
        Log.i("Restoring Purchases");
        await InAppPurchases.confirmProPurchase();
        if (AppSettings.instance.proMode) {
          Navigator.of(context).pop();
        }
      },
    );
  }
}
