import 'dart:async';

import 'package:flutter/material.dart';

import 'package:gitjournal/analytics.dart';
import 'package:gitjournal/widgets/purchase_widget.dart';

class PurchaseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pro Version'),
        ),
        body: buildBody(context),
      ),
      onWillPop: _onWillPop,
    );
  }

  Widget buildBody(BuildContext context) {
    // FIXME: This screen needs to be made way way more beautiful
    //        It's an extrememly important screen

    var features = <String>[
      "Faster feature development",
      "Note Tagging",
      "Custom Home Screen",
      "Note BackLinks",
      "Zen Mode",
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
      mainAxisSize: MainAxisSize.min,
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

    Widget w = Column(
      children: <Widget>[
        body,
        const SizedBox(height: 32.0),
        PurchaseWidget(),
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
