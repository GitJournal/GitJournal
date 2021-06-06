import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

class PurchaseThankYouScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    Widget w = Column(
      children: <Widget>[
        Text(tr('purchase_screen.thanks.title'), style: textTheme.headline3),
        Text(
          tr('purchase_screen.thanks.subtitle'),
          style: textTheme.headline4,
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(64.0, 16.0, 64.0, 16.0),
          child: ElevatedButton(
            child: const Text("Back"),
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).primaryColor),
            ),
          ),
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceAround,
    );

    return Container(
      child: SafeArea(child: w),
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.all(16.0),
    );
  }
}

// Ideas:
// 1. Add a button to share about GitJournal on Twitter / Social Media over here
