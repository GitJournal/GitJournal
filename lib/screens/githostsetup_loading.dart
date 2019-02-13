import 'package:flutter/material.dart';

class GitHostSetupLoadingPage extends StatelessWidget {
  final String text;
  GitHostSetupLoadingPage(this.text);

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.display1,
        ),
      ),
      SizedBox(height: 8.0),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircularProgressIndicator(
          value: null,
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
