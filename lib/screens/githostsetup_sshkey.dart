import 'package:flutter/material.dart';

import 'githostsetup_button.dart';

class GitHostSetupSshKey extends StatelessWidget {
  final Function doneFunction;
  final Function copyKeyFunction;
  final String publicKey;

  final Function openDeployKeyPage;
  final bool canOpenDeployKeyPage;

  GitHostSetupSshKey({
    @required this.doneFunction,
    @required this.copyKeyFunction,
    @required this.openDeployKeyPage,
    @required this.publicKey,
    @required this.canOpenDeployKeyPage,
  });

  @override
  Widget build(BuildContext context) {
    Widget copyAndDepoyWidget;
    Widget cloneButton;
    if (this.publicKey.isEmpty) {
      copyAndDepoyWidget = Container();
      cloneButton = Container();
    } else {
      cloneButton = GitHostSetupButton(
        text: "Clone Repo",
        onPressed: this.doneFunction,
      );

      if (canOpenDeployKeyPage) {
        copyAndDepoyWidget = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: RaisedButton(
                child: Text(
                  "Copy Key",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.button,
                ),
                color: Theme.of(context).primaryColor,
                onPressed: copyKeyFunction,
              ),
            ),
            SizedBox(width: 8.0),
            Expanded(
              child: RaisedButton(
                child: Text(
                  "Open Deploy Key Webpage",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.button,
                ),
                color: Theme.of(context).primaryColor,
                onPressed: openDeployKeyPage,
              ),
            ),
          ],
        );
      } else {
        copyAndDepoyWidget = GitHostSetupButton(
          text: "Copy Key",
          onPressed: this.copyKeyFunction,
        );
      }
    }

    String publicKeyStr = "";
    if (this.publicKey == null || this.publicKey.isEmpty) {
      publicKeyStr = "Generating ...";
    } else {
      publicKeyStr = this.publicKey;
    }

    var publicKeyWidget = SizedBox(
      width: double.infinity,
      height: 160.0,
      child: Container(
        color: Theme.of(context).buttonColor,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              publicKeyStr,
              textAlign: TextAlign.left,
              maxLines: null,
              style: Theme.of(context).textTheme.body1,
            ),
          ),
        ),
      ),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Deploy Public Key',
          style: Theme.of(context).textTheme.headline,
        ),
        SizedBox(height: 16.0),
        publicKeyWidget,
        SizedBox(height: 8.0),
        copyAndDepoyWidget,
        cloneButton,
      ],
    );
  }
}
