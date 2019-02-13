import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:journal/apis/githost_factory.dart';

import 'githostsetup_button.dart';

class GitCloneUrlPage extends StatefulWidget {
  final Function doneFunction;

  GitCloneUrlPage({@required this.doneFunction});

  @override
  GitCloneUrlPageState createState() {
    return GitCloneUrlPageState();
  }
}

class GitCloneUrlPageState extends State<GitCloneUrlPage> {
  final GlobalKey<FormFieldState<String>> sshUrlKey =
      GlobalKey<FormFieldState<String>>();

  final _formKey = GlobalKey<FormState>();
  final inputFormFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    final formSubmitted = () {
      if (_formKey.currentState.validate()) {
        _formKey.currentState.save();

        var url = sshUrlKey.currentState.value;
        this.widget.doneFunction(url.trim());
        inputFormFocus.unfocus();
      }
    };

    var inputForm = Form(
      key: _formKey,
      child: TextFormField(
        key: sshUrlKey,
        textAlign: TextAlign.center,
        autofocus: true,
        style: Theme.of(context).textTheme.title,
        decoration: const InputDecoration(
          hintText: 'git@github.com:GitJournal/GitJournal.git',
        ),
        validator: (String value) {
          value = value.trim();
          if (value.isEmpty) {
            return 'Please enter some text';
          }
          if (value.startsWith('https://') || value.startsWith('http://')) {
            return 'Only SSH urls are currently accepted';
          }

          RegExp regExp = RegExp(r"[a-zA-Z0-9.]+@[a-zA-Z0-9.]+:.+");
          if (!regExp.hasMatch(value)) {
            return "Invalid Input";
          }
        },
        focusNode: inputFormFocus,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (String _) => formSubmitted(),
      ),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Enter the Git Clone URL",
            style: Theme.of(context).textTheme.headline,
          ),
        ),
        SizedBox(height: 16.0),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: inputForm,
        ),
        SizedBox(height: 8.0),
        GitHostSetupButton(
          text: "Next",
          onPressed: formSubmitted,
        ),
      ],
    );
  }
}

class GitCloneUrlKnownProviderPage extends StatefulWidget {
  final Function doneFunction;
  final Function launchCreateUrlPage;
  final GitHostType gitHostType;

  GitCloneUrlKnownProviderPage({
    @required this.doneFunction,
    @required this.launchCreateUrlPage,
    @required this.gitHostType,
  });

  @override
  GitCloneUrlKnownProviderPageState createState() {
    return GitCloneUrlKnownProviderPageState();
  }
}

class GitCloneUrlKnownProviderPageState
    extends State<GitCloneUrlKnownProviderPage> {
  final GlobalKey<FormFieldState<String>> sshUrlKey =
      GlobalKey<FormFieldState<String>>();

  final _formKey = GlobalKey<FormState>();
  final inputFormFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    final formSubmitted = () {
      if (_formKey.currentState.validate()) {
        _formKey.currentState.save();

        var url = sshUrlKey.currentState.value;
        this.widget.doneFunction(url.trim());
        inputFormFocus.unfocus();
      }
    };

    var inputForm = Form(
      key: _formKey,
      child: TextFormField(
        key: sshUrlKey,
        textAlign: TextAlign.center,
        autofocus: true,
        style: Theme.of(context).textTheme.title,
        decoration: const InputDecoration(
          hintText: 'git@github.com:GitJournal/GitJournal.git',
        ),
        validator: (String value) {
          value = value.trim();
          if (value.isEmpty) {
            return 'Please enter some text';
          }
          if (value.startsWith('https://') || value.startsWith('http://')) {
            return 'Only SSH urls are currently accepted';
          }

          RegExp regExp = RegExp(r"[a-zA-Z0-9.]+@[a-zA-Z0-9.]+:.+");
          if (!regExp.hasMatch(value)) {
            return "Invalid Input";
          }
        },
        focusNode: inputFormFocus,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (String _) => formSubmitted(),
      ),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Enter the Git Clone URL",
            style: Theme.of(context).textTheme.headline,
          ),
        ),
        SizedBox(height: 8.0),
        GitHostSetupButton(
          text: "Open Create New Repo Webpage",
          onPressed: widget.launchCreateUrlPage,
        ),
        SizedBox(height: 16.0),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: inputForm,
        ),
        SizedBox(height: 8.0),
        GitHostSetupButton(
          text: "Next",
          onPressed: formSubmitted,
        ),
      ],
    );
  }
}
