import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gitjournal/analytics.dart';
import 'package:gitjournal/.env.dart';

import 'package:flutter/services.dart';
import 'package:gitjournal/settings.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseScreen extends StatefulWidget {
  @override
  _PurchaseScreenState createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  Offerings _offerings;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    Purchases.setDebugLogsEnabled(true);
    await Purchases.setup(environment['revenueCat']);

    Offerings offerings = await Purchases.getOfferings();

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _offerings = offerings;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;

    if (_offerings == null) {
      return const PurchaseLoadingScreen();
    }
    var offering = _offerings.current;
    var monthly = offering.monthly;

    // FIXME: This screen needs to be made way way more beautiful
    //        It's an extrememly important screen

    Widget w = Column(
      children: <Widget>[
        Text('Pro Version', style: textTheme.display2),
        Text('Support GitJournal by going Pro', style: textTheme.subhead),
        PurchaseButton(monthly),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceAround,
    );

    w = Container(
      child: SafeArea(child: w),
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.all(16.0),
    );

    return WillPopScope(child: w, onWillPop: _onWillPop);
  }

  Future<bool> _onWillPop() async {
    getAnalytics().logEvent(
      name: "purchase_screen_close",
    );
    return true;
  }
}

class PurchaseButton extends StatelessWidget {
  final Package package;

  PurchaseButton(this.package);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: Text('Subscribe for ${package.product.priceString} / month'),
      onPressed: () async {
        try {
          var purchaserInfo = await Purchases.purchasePackage(package);
          var isPro = purchaserInfo.entitlements.all["pro"].isActive;
          if (isPro) {
            Settings.instance.proMode = true;
            Settings.instance.save();

            // vHanda FIXME: Show some screen to indicate bought purchase?
            Navigator.of(context).pop();
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
      },
    );
  }
}

class PurchaseLoadingScreen extends StatelessWidget {
  const PurchaseLoadingScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var children = <Widget>[
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "Loading",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.display1,
        ),
      ),
      const SizedBox(height: 8.0),
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: CircularProgressIndicator(
          value: null,
        ),
      ),
    ];

    var w = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );

    return WillPopScope(
      onWillPop: _onWillPopLoading,
      child: Container(
        child: SafeArea(child: w),
        color: theme.scaffoldBackgroundColor,
        padding: const EdgeInsets.all(16.0),
      ),
    );
  }

  Future<bool> _onWillPopLoading() async {
    getAnalytics().logEvent(
      name: "purchase_screen_close_loading",
    );
    return true;
  }
}
