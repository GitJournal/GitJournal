// @dart=2.9

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

class GitHostSetupErrorPage extends StatelessWidget {
  final String errorMessage;

  GitHostSetupErrorPage(this.errorMessage);

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          tr("setup.fail"),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline4,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          errorMessage,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline4,
        ),
      ),
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}
