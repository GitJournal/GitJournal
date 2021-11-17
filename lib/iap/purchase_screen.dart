/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:gitjournal/analytics/analytics.dart';
import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/iap/purchase_manager.dart';
import 'package:gitjournal/iap/purchase_widget.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/screens/feature_timeline_screen.dart';
import 'package:gitjournal/widgets/scroll_view_without_animation.dart';

Set<String> _generateMonthlySkus() {
  var list = <String>{};
  for (var i = 0; i <= 25; i++) {
    var _ = list.add("sku_monthly_min$i");
  }
  return list;
}

Set<String> _generateYearlySkus() {
  var list = <String>{};
  for (var i = 0; i <= 20; i++) {
    var _ = list.add("sku_yearly_$i");
  }
  return list;
}

class PurchaseScreen extends StatefulWidget {
  static const routePath = '/purchase';

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

  Future<void> _fillMinYearPurchase() async {
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
          title: Text(tr(LocaleKeys.purchase_screen_title)),
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
            tr(LocaleKeys.purchase_screen_desc),
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
              const RestorePurchaseButton(),
              OutlinedButton(
                child: Text(
                  tr(LocaleKeys.feature_timeline_title),
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                onPressed: () {
                  var route = MaterialPageRoute(
                    builder: (context) => const FeatureTimelineScreen(),
                    settings: const RouteSettings(name: '/featureTimeline'),
                  );
                  var _ = Navigator.push(context, route);
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
    Key? key,
    required this.minYearlyPurchase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return PurchaseCard(
      child: Column(
        children: [
          Text(
            tr(LocaleKeys.purchase_screen_monthly_title),
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
            LocaleKeys.purchase_screen_monthly_desc,
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
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return PurchaseCard(
      child: Column(
        children: [
          Text(
            tr(LocaleKeys.purchase_screen_oneTime_title),
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
          Text(tr(LocaleKeys.purchase_screen_oneTime_desc)),
        ],
        mainAxisAlignment: MainAxisAlignment.start,
      ),
    );
  }
}

class PurchaseCard extends StatelessWidget {
  final Widget child;

  const PurchaseCard({required this.child});

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);

    return SizedBox(
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

  const PurchaseCards({required this.children});

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
