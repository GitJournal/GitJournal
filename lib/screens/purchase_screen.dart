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
        const SizedBox(height: 16.0),
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
        const SizedBox(height: 64.0),
        PurchaseWidget(),
        const SizedBox(height: 32.0),
        RestorePurchaseButton(),
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
    getAnalytics().logEvent(
      name: "purchase_screen_close",
    );
    return true;
  }
}
