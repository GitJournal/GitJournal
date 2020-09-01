import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:function_types/function_types.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/analytics.dart';
import 'package:gitjournal/iap.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/utils/logger.dart';
import 'package:gitjournal/widgets/purchase_slider.dart';

class PurchaseButton extends StatelessWidget {
  final ProductDetails product;
  final String timePeriod;
  final bool subscription;

  PurchaseButton(this.product, this.timePeriod, {@required this.subscription});

  @override
  Widget build(BuildContext context) {
    var price = product != null ? product.price : "Dev Mode";

    return RaisedButton(
      child: subscription
          ? Text('Purchase for $price / $timePeriod')
          : Text('Purchase for $price'),
      color: Theme.of(context).primaryColor,
      padding: const EdgeInsets.fromLTRB(32.0, 16.0, 32.0, 16.0),
      onPressed: product != null ? () => _initPurchase(context) : null,
    );
  }

  void _initPurchase(BuildContext context) async {
    var purchaseParam = PurchaseParam(productDetails: product);
    var sentSuccess = await InAppPurchaseConnection.instance
        .buyNonConsumable(purchaseParam: purchaseParam);

    if (!sentSuccess) {
      var err = "Failed to send purchase request";
      var dialog = PurchaseFailedDialog(err);
      await showDialog(context: context, builder: (context) => dialog);
      return;
    }

    return null;
  }
}

class PurchaseWidget extends StatefulWidget {
  final Set<String> skus;
  final String defaultSku;
  final String timePeriod;
  final bool isSubscription;
  final Func1<String, void> minPurchaseOptionCallback;

  PurchaseWidget({
    @required this.skus,
    @required this.defaultSku,
    @required this.timePeriod,
    @required this.isSubscription,
    this.minPurchaseOptionCallback,
  });

  @override
  _PurchaseWidgetState createState() => _PurchaseWidgetState();
}

class _PurchaseWidgetState extends State<PurchaseWidget> {
  List<ProductDetails> _products;
  ProductDetails _selectedProduct;
  StreamSubscription<List<PurchaseDetails>> _subscription;

  String error = "";
  bool pendingPurchase = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    InAppPurchaseConnection.enablePendingPurchases();
    final iapCon = InAppPurchaseConnection.instance;

    final bool available = await iapCon.isAvailable();
    if (!available) {
      setState(() {
        error = "Store cannot be reached";
      });
      return;
    }

    final response = await iapCon.queryProductDetails(widget.skus);
    if (response.error != null) {
      Log.e("IAP queryProductDetails: ${response.error}");
    }
    var products = response.productDetails;
    products.sort((a, b) {
      var pa = _fromProductDetail(a);
      var pb = _fromProductDetail(b);
      return pa.value.compareTo(pb.value);
    });
    Log.i("Products: ${products.length}");
    for (var p in products) {
      Log.i("Product ${p.id} -> ${p.price}");
    }
    if (widget.minPurchaseOptionCallback != null && products.isNotEmpty) {
      Log.i("Calling minPurchaseOptionCallback with ${products.first.price}");
      widget.minPurchaseOptionCallback(products.first.price);
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _products = products;
      _selectedProduct = _products.isNotEmpty ? _products.first : null;

      if (_products.length > 1) {
        for (var p in _products) {
          if (p.id == widget.defaultSku) {
            _selectedProduct = p;
            break;
          }
        }
      } else {
        // FIXME: Add a fake product for development
      }
    });

    // Start listening for changes
    final purchaseUpdates = iapCon.purchaseUpdatedStream;
    _subscription = purchaseUpdates.listen(_listenToPurchaseUpdated);
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        //showPendingUI();
        Log.i("Pending - ${purchaseDetails.productID}");
        setState(() {
          pendingPurchase = true;
        });
        return;
      }

      setState(() {
        pendingPurchase = false;
      });
      if (purchaseDetails.status == PurchaseStatus.error) {
        _handleIAPError(purchaseDetails.error);
        return;
      } else if (purchaseDetails.status == PurchaseStatus.purchased) {
        var subStatus = await verifyPurchase(purchaseDetails);
        if (subStatus.isPro) {
          _deliverProduct(subStatus);
        } else {
          _handleError("Failed to purchase product");
          return;
        }
      }
      if (purchaseDetails.pendingCompletePurchase) {
        Log.i("Pending Complete Purchase - ${purchaseDetails.productID}");

        await InAppPurchaseConnection.instance
            .completePurchase(purchaseDetails);
      }
    });
  }

  void _handleIAPError(IAPError err) {
    var msg = "${err.code} - ${err.message} - ${err.details}";
    _handleError(msg);
  }

  void _handleError(String err) {
    var dialog = PurchaseFailedDialog(err);
    showDialog(context: context, builder: (context) => dialog);
  }

  void _deliverProduct(SubscriptionStatus status) {
    var settings = Provider.of<Settings>(context);
    settings.proMode = status.isPro;
    settings.proExpirationDate = status.expiryDate.toIso8601String();
    settings.save();

    logEvent(Event.PurchaseScreenThankYou);
    Navigator.of(context).popAndPushNamed('/purchase_thank_you');
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (error.isNotEmpty) {
      return Text("Failed to load: $error");
    }
    if (pendingPurchase) {
      return const CircularProgressIndicator();
    }
    return _products == null
        ? const CircularProgressIndicator()
        : buildBody(context);
  }

  PaymentInfo _fromProductDetail(ProductDetails pd) {
    if (pd == null) return null;

    double value = -1;
    if (pd.skProduct != null) {
      value = double.parse(pd.skProduct.price);
    } else if (pd.skuDetail != null) {
      value = pd.skuDetail.originalPriceAmountMicros.toDouble() / 100000;
    }

    return PaymentInfo(
      id: pd.id,
      text: pd.price,
      value: value,
    );
  }

  ProductDetails _fromPaymentInfo(PaymentInfo info) {
    for (var p in _products) {
      if (p.id == info.id) {
        return p;
      }
    }
    assert(false);
    return null;
  }

  Widget buildBody(BuildContext context) {
    var slider = PurchaseSlider(
      values: _products.map(_fromProductDetail).toList(),
      selectedValue: _fromProductDetail(_selectedProduct),
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
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceAround,
    );
  }

  ProductDetails _prevProduct() {
    for (var i = 0; i < _products.length; i++) {
      if (_products[i] == _selectedProduct) {
        return i > 0 ? _products[i - 1] : _products[i];
      }
    }

    return null;
  }

  ProductDetails _nextProduct() {
    for (var i = 0; i < _products.length; i++) {
      if (_products[i] == _selectedProduct) {
        return i < _products.length - 1 ? _products[i + 1] : _products[i];
      }
    }

    return null;
  }
}

class _PurchaseSliderButton extends StatelessWidget {
  final Widget icon;
  final Function onPressed;

  _PurchaseSliderButton({@required this.icon, @required this.onPressed});

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
      title: const Text("Purchase Failed"),
      content: Text(text),
      actions: <Widget>[
        FlatButton(
          child: const Text("OK"),
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

    return OutlineButton(
      child: Text(text),
      onPressed: () async {
        setState(() {
          computing = true;
        });
        await InAppPurchases.confirmProPurchase();
        if (Settings.instance.proMode) {
          Navigator.of(context).pop();
        }
      },
    );
  }
}
