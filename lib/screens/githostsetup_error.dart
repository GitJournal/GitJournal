import 'package:flutter/material.dart';

class GitHostSetupErrorPage extends StatelessWidget {
  final String errorMessage;

  GitHostSetupErrorPage(this.errorMessage);

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Failed',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.display1,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          errorMessage,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.display1,
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
