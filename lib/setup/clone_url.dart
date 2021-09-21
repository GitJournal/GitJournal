/*
 * SPDX-FileCopyrightText: 2020-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dart_git/git_url_parse.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:function_types/function_types.dart';

import 'package:gitjournal/apis/githost_factory.dart';
import 'package:gitjournal/generated/locale_keys.g.dart';
import 'button.dart';

class GitCloneUrlPage extends StatefulWidget {
  final Func1<String, void> doneFunction;
  final String initialValue;

  const GitCloneUrlPage({
    required this.doneFunction,
    required this.initialValue,
    Key? key,
  }) : super(key: key);

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
    void formSubmitted() {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();

        var url = sshUrlKey.currentState!.value!;
        widget.doneFunction(url.trim());
        inputFormFocus.unfocus();
      }
    }

    var inputForm = Form(
      key: _formKey,
      child: TextFormField(
        key: sshUrlKey,
        textAlign: TextAlign.center,
        autofocus: true,
        style: Theme.of(context).textTheme.subtitle1,
        decoration: const InputDecoration(
          hintText: 'git@github.com:GitJournal/GitJournal.git',
        ),
        validator: _isCloneUrlValid,
        focusNode: inputFormFocus,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (String _) => formSubmitted(),
        initialValue: widget.initialValue,
        autocorrect: false,
      ),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            LocaleKeys.setup_cloneUrl_enter.tr(),
            style: Theme.of(context).textTheme.headline5,
          ),
        ),
        const SizedBox(height: 16.0),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: inputForm,
        ),
        const SizedBox(height: 8.0),
        GitHostSetupButton(
          text: LocaleKeys.setup_next.tr(),
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

  const GitCloneUrlKnownProviderPage({
    required this.doneFunction,
    required this.launchCreateUrlPage,
    required this.gitHostType,
    required this.initialValue,
    Key? key,
  }) : super(key: key);

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
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();

        var url = sshUrlKey.currentState!.value!;
        widget.doneFunction(_cleanupGitUrl(url));
        inputFormFocus.unfocus();
      }
    };

    var inputForm = Form(
      key: _formKey,
      child: TextFormField(
        key: sshUrlKey,
        textAlign: TextAlign.center,
        autofocus: true,
        style: Theme.of(context).textTheme.subtitle1,
        decoration: const InputDecoration(
          hintText: 'git@github.com:GitJournal/GitJournal.git',
        ),
        validator: _isCloneUrlValid,
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
          LocaleKeys.setup_cloneUrl_manual_title.tr(),
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(height: 32.0),

        // Step 1
        Text(
          LocaleKeys.setup_cloneUrl_manual_step1.tr(),
          style: Theme.of(context).textTheme.subtitle2,
        ),
        const SizedBox(height: 8.0),
        GitHostSetupButton(
          text: LocaleKeys.setup_cloneUrl_manual_button.tr(),
          onPressed: widget.launchCreateUrlPage,
        ),
        const SizedBox(height: 16.0),

        // Step 2
        Text(
          LocaleKeys.setup_cloneUrl_manual_step2.tr(),
          style: Theme.of(context).textTheme.subtitle2,
        ),
        const SizedBox(height: 8.0),
        inputForm,
        const SizedBox(height: 16.0),
        GitHostSetupButton(
          text: LocaleKeys.setup_next.tr(),
          onPressed: formSubmitted,
        ),
      ],
    );
  }
}

// Returns null when valid
String? _isCloneUrlValid(String? url) {
  if (url == null) {
    return LocaleKeys.setup_cloneUrl_validator_empty.tr();
  }
  url = _cleanupGitUrl(url);
  if (url.isEmpty) {
    return LocaleKeys.setup_cloneUrl_validator_empty.tr();
  }

  var result = gitUrlParse(url);
  if (result == null) {
    return LocaleKeys.setup_cloneUrl_validator_invalid.tr();
  }

  if (result.protocol != 'ssh') {
    return LocaleKeys.setup_cloneUrl_validator_onlySsh.tr();
  }

  return null;
}

String _cleanupGitUrl(String url) {
  const gitHub = 'git@github.com';
  const gitLab = 'git@gitlab.com';

  if (url.startsWith('$gitHub/')) {
    url = url.replaceFirst('$gitHub/', '$gitHub:');
  } else if (url.startsWith('$gitLab/')) {
    url = url.replaceFirst('$gitLab/', '$gitLab:');
  }

  return url.trim();
}
