import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:function_types/function_types.dart';
import 'package:gitjournal/apis/githost_factory.dart';

import 'githostsetup_button.dart';

class GitCloneUrlPage extends StatefulWidget {
  final Func1<String, void> doneFunction;
  final String initialValue;

  GitCloneUrlPage({
    @required this.doneFunction,
    @required this.initialValue,
  });

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
        widget.doneFunction(url.trim());
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

          RegExp regExp = RegExp(r"[a-zA-Z0-9.]+@[a-zA-Z0-9.-]+:.+");
          if (!regExp.hasMatch(value)) {
            return "Invalid Input";
          }

          return null;
        },
        focusNode: inputFormFocus,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (String _) => formSubmitted(),
        initialValue: widget.initialValue,
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
        const SizedBox(height: 16.0),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: inputForm,
        ),
        const SizedBox(height: 8.0),
        GitHostSetupButton(
          text: "Next",
          onPressed: formSubmitted,
        ),
      ],
    );
  }
}

class GitCloneUrlKnownProviderPage extends StatefulWidget {
  final Func1<String, void> doneFunction;
  final Func0<void> launchCreateUrlPage;
  final GitHostType gitHostType;
  final String initialValue;

  GitCloneUrlKnownProviderPage({
    @required this.doneFunction,
    @required this.launchCreateUrlPage,
    @required this.gitHostType,
    @required this.initialValue,
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
        widget.doneFunction(url.trim());
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

          return null;
        },
        focusNode: inputFormFocus,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (String _) => formSubmitted(),
        initialValue: widget.initialValue,
      ),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Please create a new git repository -',
          style: Theme.of(context).textTheme.title,
        ),
        const SizedBox(height: 32.0),

        // Step 1
        Text(
          '1. Go to the website, create a repo and copy its git clone URL',
          style: Theme.of(context).textTheme.subtitle,
        ),
        const SizedBox(height: 8.0),
        GitHostSetupButton(
          text: "Open Create New Repo Webpage",
          onPressed: widget.launchCreateUrlPage,
        ),
        const SizedBox(height: 16.0),

        // Step 2
        Text(
          '2. Enter the Git clone URL',
          style: Theme.of(context).textTheme.subtitle,
        ),
        const SizedBox(height: 8.0),
        inputForm,
        const SizedBox(height: 16.0),
        GitHostSetupButton(
          text: "Next",
          onPressed: formSubmitted,
        ),
      ],
    );
  }
}
