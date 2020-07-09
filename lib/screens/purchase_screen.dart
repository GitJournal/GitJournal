import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:gitjournal/analytics.dart';
import 'package:gitjournal/widgets/purchase_widget.dart';

class PurchaseScreen extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: EmptyAppBar(),
        body: buildBody(context),
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
      "Note BackLinks",
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

    Widget w = Column(
      children: <Widget>[
        Text(
          'Pro Version',
          style: titleStyle,
          textAlign: TextAlign.center,
        ),
        body,
        PurchaseWidget(),
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
