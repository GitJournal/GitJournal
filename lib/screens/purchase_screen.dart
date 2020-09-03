import 'dart:async';

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:function_types/function_types.dart';

import 'package:gitjournal/analytics.dart';
import 'package:gitjournal/screens/feature_timeline_screen.dart';
import 'package:gitjournal/widgets/purchase_widget.dart';
import 'package:gitjournal/widgets/scroll_view_without_animation.dart';

class PurchaseScreen extends StatefulWidget {
  @override
  _PurchaseScreenState createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  String minYearlyPurchase = "";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr('purchase_screen.title')),
        ),
        body: buildBody(context),
      ),
      onWillPop: _onWillPop,
    );
  }

  Widget buildBody(BuildContext context) {
    Widget w = Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
          child: Text(
            tr('purchase_screen.desc'),
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ),
        const SizedBox(height: 32.0),
        PurchaseCards(
          children: [
            const SizedBox(width: 16.0),
            YearlyPurchaseWidget(minPurchaseOptionCallback: (val) {
              setState(() {
                minYearlyPurchase = val;
              });
            }),
            const SizedBox(width: 16.0),
            MonthlyRentalWidget(minYearlyPurchase: minYearlyPurchase),
            const SizedBox(width: 16.0),
          ],
        ),
        const SizedBox(height: 32.0),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
          child: Row(
            children: [
              RestorePurchaseButton(),
              OutlineButton(
                child: Text(tr("feature_timeline.title")),
                onPressed: () {
                  var route = MaterialPageRoute(
                    builder: (context) => FeatureTimelineScreen(),
                    settings: const RouteSettings(name: '/featureTimeline'),
                  );
                  Navigator.of(context).push(route);
                },
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
    );

    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: w,
        ),
      ],
    );
  }

  Future<bool> _onWillPop() async {
    logEvent(Event.PurchaseScreenClose);
    return true;
  }
}

class MonthlyRentalWidget extends StatelessWidget {
  final String minYearlyPurchase;

  const MonthlyRentalWidget({
    Key key,
    @required this.minYearlyPurchase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return PurchaseCard(
      child: Column(
        children: [
          Text(tr('purchase_screen.monthly.title'), style: textTheme.headline5),
          const SizedBox(height: 32.0),
          PurchaseWidget(
            skus: _generateSkus(),
            defaultSku: "sku_monthly_min3",
            timePeriod: "Month",
            isSubscription: true,
          ),
          const SizedBox(height: 32.0),
          Text(tr(
            "purchase_screen.monthly.desc",
            namedArgs: {'minYearlyPurchase': minYearlyPurchase},
          )),
        ],
        mainAxisAlignment: MainAxisAlignment.start,
      ),
    );
  }

  Set<String> _generateSkus() {
    var list = <String>{};
    for (var i = 0; i <= 25; i++) {
      list.add("sku_monthly_min$i");
    }
    return list;
  }
}

class YearlyPurchaseWidget extends StatelessWidget {
  final Func1<String, void> minPurchaseOptionCallback;

  const YearlyPurchaseWidget({
    Key key,
    @required this.minPurchaseOptionCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return PurchaseCard(
      child: Column(
        children: [
          Text(tr('purchase_screen.oneTime.title'), style: textTheme.headline5),
          const SizedBox(height: 32.0),
          PurchaseWidget(
            skus: _generateSkus(),
            defaultSku: "sku_yearly_1",
            isSubscription: false,
            minPurchaseOptionCallback: minPurchaseOptionCallback,
          ),
          const SizedBox(height: 32.0),
          Text(tr('purchase_screen.oneTime.desc')),
        ],
        mainAxisAlignment: MainAxisAlignment.start,
      ),
    );
  }

  Set<String> _generateSkus() {
    var list = <String>{};
    for (var i = 0; i <= 20; i++) {
      list.add("sku_yearly_$i");
    }
    return list;
  }
}

class PurchaseCard extends StatelessWidget {
  final Widget child;

  PurchaseCard({@required this.child});

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);

    return Container(
      width: mediaQuery.size.width * 0.80,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
          child: child,
        ),
      ),
    );
  }
}

class PurchaseCards extends StatelessWidget {
  final List<Widget> children;

  PurchaseCards({@required this.children});

  @override
  Widget build(BuildContext context) {
    return ScrollViewWithoutAnimation(
      scrollDirection: Axis.horizontal,
      child: IntrinsicHeight(
        child: Row(
          children: children,
          mainAxisSize: MainAxisSize.min,
        ),
      ),
    );
  }
}
