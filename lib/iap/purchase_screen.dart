/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gitjournal/analytics/analytics.dart';
import 'package:gitjournal/iap/purchase_manager.dart';
import 'package:gitjournal/iap/purchase_widget.dart';
import 'package:gitjournal/iap/restore_purchase_button.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/widgets/scroll_view_without_animation.dart';

Set<String> _generateYearlySkus() {
  var list = <String>{};
  for (var i = 0; i <= 20; i++) {
    list.add("sku_yearly_$i");
  }
  return list;
}

class PurchaseScreen extends StatefulWidget {
  static const routePath = '/purchase';

  @override
  _PurchaseScreenState createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
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
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.loc.purchaseScreenTitle),
        ),
        body: buildBody(context),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    Widget w = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
          child: Text(
            context.loc.purchaseScreenDesc,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 32.0),
        const PurchaseCards(
          children: [
            SizedBox(width: 16.0),
            YearlyPurchaseWidget(),
            SizedBox(width: 16.0),
          ],
        ),
        const SizedBox(height: 32.0),
        const Padding(
          padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
          child: RestorePurchaseButton(),
        ),
      ],
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

class YearlyPurchaseWidget extends StatelessWidget {
  const YearlyPurchaseWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return PurchaseCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            context.loc.purchaseScreenOneTimeTitle,
            style: textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32.0),
          PurchaseWidget(
            skus: _generateYearlySkus(),
            defaultSku: "sku_yearly_1",
            isSubscription: false,
          ),
          const SizedBox(height: 32.0),
          Text(context.loc.purchaseScreenOneTimeDesc),
        ],
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
      width: mediaQuery.size.width * 0.8,
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
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}
