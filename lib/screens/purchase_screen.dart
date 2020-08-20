import 'dart:async';

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:gitjournal/analytics.dart';
import 'package:gitjournal/screens/feature_timeline_screen.dart';
import 'package:gitjournal/widgets/purchase_widget.dart';

class PurchaseScreen extends StatelessWidget {
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
        Text(
          tr('purchase_screen.desc'),
          style: Theme.of(context).textTheme.bodyText2,
        ),
        const SizedBox(height: 32.0),
        PurchaseCards(
          children: [
            const MonthlyRentalWidget(),
            const YearlyPurchaseWidget(),
          ],
        ),
        const SizedBox(height: 32.0),
        Row(
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
      ],
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
    );

    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(padding: const EdgeInsets.all(16.0), child: w),
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
  const MonthlyRentalWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return PurchaseCard(
      child: Column(
        children: [
          // TODO: Translate this
          Text("Monthly Rental", style: textTheme.headline5),
          const SizedBox(height: 32.0),
          PurchaseWidget(
            skus: _generateSkus(),
            defaultSku: "sku_monthly_min3",
            timePeriod: "Month",
          ),
          const SizedBox(height: 32.0),
          const Text(
              "After 12 months of rental or after paying the min yearly amount, you will automatically get all the benefits of a Yearly Purchase."),
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
  const YearlyPurchaseWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return PurchaseCard(
      child: Column(
        children: [
          Text("Yearly Purchase", style: textTheme.headline5),
          const SizedBox(height: 32.0),
          PurchaseWidget(
            skus: _generateSkus(),
            defaultSku: "sku_sub_yearly_1",
            timePeriod: "Year",
          ),
          const SizedBox(height: 32.0),
          const Text(
              "Enables all Pro features currently in GitJournal and new features added in the following 12 months. These features will be yours forever.")
        ],
        mainAxisAlignment: MainAxisAlignment.start,
      ),
    );
  }

  Set<String> _generateSkus() {
    var list = <String>{};
    for (var i = 0; i <= 20; i++) {
      list.add("sku_sub_yearly_$i");
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

class PurchaseCards extends StatefulWidget {
  final List<Widget> children;

  PurchaseCards({@required this.children});

  @override
  _PurchaseCardsState createState() => _PurchaseCardsState();
}

class _PurchaseCardsState extends State<PurchaseCards> {
  @override
  Widget build(BuildContext context) {
    return _ScrollViewWithoutAnim(
      scrollDirection: Axis.horizontal,
      child: IntrinsicHeight(
        child: Row(
          children: widget.children,
          mainAxisSize: MainAxisSize.min,
        ),
      ),
    );
  }
}

class _ScrollViewWithoutAnim extends StatelessWidget {
  final Widget child;
  final Axis scrollDirection;

  _ScrollViewWithoutAnim({
    @required this.child,
    this.scrollDirection,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (OverscrollIndicatorNotification overScroll) {
        overScroll.disallowGlow();
        return false;
      },
      child: SingleChildScrollView(
        scrollDirection: scrollDirection,
        child: child,
      ),
    );
  }
}
