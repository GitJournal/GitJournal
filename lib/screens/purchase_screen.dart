import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gitjournal/analytics.dart';

import 'package:flutter/services.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

class PurchaseScreen extends StatefulWidget {
  @override
  _PurchaseScreenState createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  String _platformVersion = 'Unknown';
  var _skus = ['sku_monthly_min'];
  List<IAPItem> _iapItems = [];

  StreamSubscription _purchaseUpdatedSubscription;
  StreamSubscription _purchaseErrorSubscription;
  StreamSubscription _conectionSubscription;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    // prepare
    var result = await FlutterInappPurchase.instance.initConnection;
    print('result: $result');

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    try {
      _iapItems = await FlutterInappPurchase.instance.getSubscriptions(_skus);
      setState(() {});
      print("IAP ITEMS $_iapItems");
    } catch (err) {
      print('getSubscriptions error: $err');
    }

    _conectionSubscription =
        FlutterInappPurchase.connectionUpdated.listen((connected) {
      print('connected: $connected');
    });

    _purchaseUpdatedSubscription =
        FlutterInappPurchase.purchaseUpdated.listen((productItem) {
      print('purchase-updated: $productItem');
    });

    _purchaseErrorSubscription =
        FlutterInappPurchase.purchaseError.listen((purchaseError) {
      print('purchase-error: $purchaseError');
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;

    if (_iapItems.isEmpty) {
      return const PurchaseLoadingScreen();
    }
    var iap = _iapItems[0];

    // FIXME: This screen needs to be made way way more beautiful
    //        It's an extrememly important screen

    Widget w = Column(
      children: <Widget>[
        Text('Pro Version', style: textTheme.display2),
        Text('Support GitJournal by going Pro', style: textTheme.subhead),
        RaisedButton(
          child: Text('Subscribe for ${iap.localizedPrice} / month'),
          onPressed: () {
            FlutterInappPurchase.instance.requestSubscription(_skus[0]);
          },
        ),
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
