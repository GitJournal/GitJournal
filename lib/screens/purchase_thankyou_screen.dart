import 'package:flutter/material.dart';

class PurchaseThankYouScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    Widget w = Column(
      children: <Widget>[
        Text('Thank you', style: textTheme.headline3),
        Text(
          "You're awesome for supporting GitJournal",
          style: textTheme.headline4,
          textAlign: TextAlign.center,
        ),
        RaisedButton(
          child: const Text("Back"),
          color: theme.primaryColor,
          onPressed: () {
            Navigator.of(context).pop();
          },
          padding: const EdgeInsets.fromLTRB(64.0, 16.0, 64.0, 16.0),
        )
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
