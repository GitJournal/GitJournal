import 'dart:async';

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:gitjournal/analytics.dart';
import 'package:gitjournal/purchase_manager.dart';
import 'package:gitjournal/screens/feature_timeline_screen.dart';
import 'package:gitjournal/utils/logger.dart';
import 'package:gitjournal/widgets/purchase_widget.dart';
import 'package:gitjournal/widgets/scroll_view_without_animation.dart';

Set<String> _generateMonthlySkus() {
  var list = <String>{};
  for (var i = 0; i <= 25; i++) {
    list.add("sku_monthly_min$i");
  }
  return list;
}

Set<String> _generateYearlySkus() {
  var list = <String>{};
  for (var i = 0; i <= 20; i++) {
    list.add("sku_yearly_$i");
  }
  return list;
}

class PurchaseScreen extends StatefulWidget {
  @override
  _PurchaseScreenState createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  String minYearlyPurchase = "";

  @override
  void initState() {
    _fillMinYearPurchase();
    super.initState();
  }

  void _fillMinYearPurchase() async {
    var pm = await PurchaseManager.init();
    if (pm == null) return;

    if (!mounted) return;

    var response = await pm.queryProductDetails(_generateYearlySkus());
    if (response.error != null) {
      Log.e("IAP queryProductDetails: ${response.error}");
    }

    if (!mounted) return;
    if (response.productDetails.isEmpty) return;

    setState(() {
      minYearlyPurchase = response.productDetails.first.price;
    });
  }

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
            const YearlyPurchaseWidget(),
            const SizedBox(width: 16.0),
            MonthlyRentalWidget(minYearlyPurchase: minYearlyPurchase),
            const SizedBox(width: 16.0),
          ],
        ),
        const SizedBox(height: 32.0),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
          child: Wrap(
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
            alignment: WrapAlignment.spaceEvenly,
            direction: Axis.horizontal,
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
          Text(
            tr('purchase_screen.monthly.title'),
            style: textTheme.headline5,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32.0),
          PurchaseWidget(
            skus: _generateMonthlySkus(),
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
}

class YearlyPurchaseWidget extends StatelessWidget {
  const YearlyPurchaseWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return PurchaseCard(
      child: Column(
        children: [
          Text(
            tr('purchase_screen.oneTime.title'),
            style: textTheme.headline5,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32.0),
          PurchaseWidget(
            skus: _generateYearlySkus(),
            defaultSku: "sku_yearly_1",
            isSubscription: false,
          ),
          const SizedBox(height: 32.0),
          Text(tr('purchase_screen.oneTime.desc')),
        ],
        mainAxisAlignment: MainAxisAlignment.start,
      ),
    );
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
