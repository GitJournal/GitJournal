import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:gitjournal/analytics.dart';
import 'package:gitjournal/.env.dart';
import 'package:gitjournal/iap.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/widgets/purchase_slider.dart';

import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseButton extends StatelessWidget {
  final Package package;

  PurchaseButton(this.package);

  @override
  Widget build(BuildContext context) {
    var price = package != null ? package.product.priceString : "Dev Mode";

    return RaisedButton(
      child: Text('Subscribe for $price / month'),
      color: Theme.of(context).primaryColor,
      padding: const EdgeInsets.fromLTRB(32.0, 16.0, 32.0, 16.0),
      onPressed: package != null ? () => _handlePurchase(context) : null,
    );
  }

  void _handlePurchase(BuildContext context) async {
    try {
      var purchaserInfo = await Purchases.purchasePackage(package);
      var isPro = purchaserInfo.entitlements.all["pro"].isActive;
      if (isPro) {
        Settings.instance.proMode = true;
        Settings.instance.proExpirationDate =
            purchaserInfo.latestExpirationDate;
        Settings.instance.save();

        getAnalytics().logEvent(
          name: "purchase_screen_thank_you",
        );

        Navigator.of(context).popAndPushNamed('/purchase_thank_you');
        return;
      }
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      var errorContent = "";
      switch (errorCode) {
        case PurchasesErrorCode.purchaseCancelledError:
          errorContent = "User cancelled";
          break;

        case PurchasesErrorCode.purchaseNotAllowedError:
          errorContent = "User not allowed to purchase";
          break;

        default:
          errorContent = errorCode.toString();
          break;
      }

      var dialog = AlertDialog(
        title: const Text("Purchase Failed"),
        content: Text(errorContent),
        actions: <Widget>[
          FlatButton(
            child: const Text("OK"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
      await showDialog(context: context, builder: (context) => dialog);
    }
    return null;
  }
}

class PurchaseWidget extends StatefulWidget {
  @override
  _PurchaseWidgetState createState() => _PurchaseWidgetState();
}

class _PurchaseWidgetState extends State<PurchaseWidget> {
  List<Offering> _offerings;
  Offering _selectedOffering;
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    await InAppPurchases.confirmProPurchase();
    if (Settings.instance.proMode) {
      Navigator.of(context).pop();
    }

    await Purchases.setup(
      environment['revenueCat'],
      appUserId: Settings.instance.pseudoId,
    );

    Offerings offerings;
    try {
      offerings = await Purchases.getOfferings();
    } catch (e) {
      if (e is PlatformException) {
        var snackBar = SnackBar(content: Text(e.message));
        _scaffoldKey.currentState
          ..removeCurrentSnackBar()
          ..showSnackBar(snackBar);
        return;
      }
    }
    var offeringList = offerings.all.values.toList();
    offeringList.retainWhere((Offering o) => o.identifier.contains("monthly"));
    offeringList.sort((Offering a, Offering b) =>
        a.monthly.product.price.compareTo(b.monthly.product.price));
    print("Offerings: $offeringList");

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _offerings = offeringList;
      _selectedOffering = _offerings.isNotEmpty ? _offerings.first : null;

      if (_offerings.length > 1) {
        _selectedOffering = _offerings[1];
      } else {
        var fakePackageJson = {
          'identifier': 'monthly_fake',
          'product': {
            'identifier': 'fake_product',
            'title': 'Fake Product',
            'priceString': '0 Fake',
            'price': 0.0,
          },
        };

        var fakeOffer = Offering.fromJson(<String, dynamic>{
          'identifier': 'monthly_fake_offering',
          'monthly': fakePackageJson,
          'availablePackages': [fakePackageJson],
        });

        _offerings = [fakeOffer];
        _selectedOffering = _offerings[0];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _offerings == null
        ? const CircularProgressIndicator()
        : buildBody(context);
  }

  PaymentInfo _fromOffering(Offering o) {
    var prod = o.monthly.product;
    return PaymentInfo(prod.price, prod.priceString);
  }

  Offering _fromPaymentInfo(PaymentInfo info) {
    for (var o in _offerings) {
      if (o.monthly.product.priceString == info.text) {
        return o;
      }
    }
    assert(false);
    return null;
  }

  Widget buildBody(BuildContext context) {
    var slider = PurchaseSlider(
      values: _offerings.map(_fromOffering).toList(),
      selectedValue: _fromOffering(_selectedOffering),
      onChanged: (PaymentInfo info) {
        setState(() {
          _selectedOffering = _fromPaymentInfo(info);
        });
      },
    );

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            _PurchaseSliderButton(
              icon: Icon(Icons.arrow_left),
              onPressed: () {
                setState(() {
                  _selectedOffering = _prevOffering();
                });
              },
            ),
            Expanded(child: slider),
            _PurchaseSliderButton(
              icon: Icon(Icons.arrow_right),
              onPressed: () {
                setState(() {
                  _selectedOffering = _nextOffering();
                });
              },
            ),
          ],
          mainAxisSize: MainAxisSize.max,
        ),
        const SizedBox(height: 16.0),
        PurchaseButton(_selectedOffering?.monthly),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceAround,
    );
  }

  Offering _prevOffering() {
    for (var i = 0; i < _offerings.length; i++) {
      if (_offerings[i] == _selectedOffering) {
        return i > 0 ? _offerings[i - 1] : _offerings[i];
      }
    }

    return null;
  }

  Offering _nextOffering() {
    for (var i = 0; i < _offerings.length; i++) {
      if (_offerings[i] == _selectedOffering) {
        return i < _offerings.length - 1 ? _offerings[i + 1] : _offerings[i];
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
