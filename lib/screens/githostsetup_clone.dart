import 'package:flutter/material.dart';

class GitHostSetupGitClone extends StatelessWidget {
  final String errorMessage;

  GitHostSetupGitClone({
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];
    if (this.errorMessage == null || this.errorMessage.isEmpty) {
      children = <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Cloning ...',
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
    } else {
      children = <Widget>[
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
            this.errorMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.display1,
          ),
        ),
      ];
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}
