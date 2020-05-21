import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:gitjournal/analytics.dart';
import 'package:gitjournal/.env.dart';
import 'package:gitjournal/settings.dart';

import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseScreen extends StatefulWidget {
  @override
  _PurchaseScreenState createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  List<Offering> _offerings;
  Offering _selectedOffering;
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    Purchases.setDebugLogsEnabled(true);
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
    return WillPopScope(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: EmptyAppBar(),
        body: _offerings == null ? const LoadingWidget() : buildBody(context),
      ),
      onWillPop: _onWillPop,
    );
  }

  Widget buildBody(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;

    // FIXME: This screen needs to be made way way more beautiful
    //        It's an extrememly important screen

    var features = <String>[
      "Faster feature development",
      "Note Tagging",
      "Custom Home Screen",
      "Multiple Git Repos (coming soon)",
      "Custom settings per folder (coming soon)",
      "View and search through your entire Git Log (coming soon)",
      "Custom Git commits (coming soon)",
      "Note Templates (comming soon)",
      "Unlimited Pinned Folders / Queries (coming soon)",
      "End-to-End encrypted Git Hosting (coming soon)",
      "Maybe even your own custom feature (email me).",
      "GitJournal stays Ad free",
    ];

    var body = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Support GitJournal by going Pro and additionally get -',
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(height: 16.0),
        for (var f in features)
          Column(
            children: <Widget>[
              Text(
                "• $f",
                style: Theme.of(context).textTheme.bodyText1,
              ),
              const SizedBox(height: 8.0),
            ],
          ),
      ],
    );

    var titleStyle =
        textTheme.headline3.copyWith(color: textTheme.headline6.color);
    var slider = Slider(
      min: _offerings.first.monthly.product.price,
      max: _offerings.last.monthly.product.price + 0.50,
      value: _selectedOffering.monthly.product.price,
      onChanged: (double val) {
        int i = -1;
        for (i = 1; i < _offerings.length; i++) {
          var prev = _offerings[i - 1].monthly.product;
          var cur = _offerings[i].monthly.product;

          if (prev.price < val && val <= cur.price) {
            i--;
            break;
          }
        }
        if (val == _offerings.first.monthly.product.price) {
          i = 0;
        } else if (val >= _offerings.last.monthly.product.price) {
          i = _offerings.length - 1;
        }

        if (i != -1) {
          setState(() {
            _selectedOffering = _offerings[i];
          });
        }
      },
      label: _selectedOffering.monthly.product.priceString,
      divisions: _offerings.length,
    );

    Widget w = Column(
      children: <Widget>[
        Text(
          'Pro Version',
          style: titleStyle,
          textAlign: TextAlign.center,
        ),
        body,
        slider,
        PurchaseButton(_selectedOffering?.monthly),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceAround,
    );

    if (Platform.isIOS) {
      w = Stack(
        alignment: FractionalOffset.topLeft,
        children: <Widget>[
          w,
          InkWell(
            child: Container(
              child: const Icon(Icons.arrow_back, size: 32.0),
              padding: const EdgeInsets.all(8.0),
            ),
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      );
    }

    return _SingleChildScrollViewExpanded(
      child: SafeArea(child: w),
      padding: const EdgeInsets.all(16.0),
    );
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

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var children = <Widget>[
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "Loading",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline4,
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
        child: w,
        color: theme.scaffoldBackgroundColor,
        padding: const EdgeInsets.all(16.0),
        constraints: const BoxConstraints.expand(),
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

class EmptyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Container(color: Theme.of(context).primaryColor);
  }

  @override
  Size get preferredSize => const Size(0.0, 0.0);
}

class _SingleChildScrollViewExpanded extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  _SingleChildScrollViewExpanded({this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(
                height: max(100, constraints.maxHeight)),
            child: child,
          ),
          padding: padding,
        );
      },
    );
  }
}
