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
        const MonthlyRentalWidget(),
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

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 32.0),
        child: Column(
          children: [
            Text("Monthly Subscription", style: textTheme.headline5),
            const SizedBox(height: 32.0),
            PurchaseWidget(
              skus: _generateSkus(),
              defaultSku: "sku_monthly_min3",
              timePeriod: "Month",
            ),
          ],
        ),
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

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 32.0),
        child: Column(
          children: [
            Text("Yearly Purchase", style: textTheme.headline5),
            const SizedBox(height: 32.0),
            PurchaseWidget(
              skus: _generateSkus(),
              defaultSku: "sku_sub_yearly_0",
              timePeriod: "Year",
            ),
            const SizedBox(height: 8.0),
            const Text(
                "Enables all Pro features currently in GitJournal and new ones added the next year. These features will be yours forever.")
          ],
        ),
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
