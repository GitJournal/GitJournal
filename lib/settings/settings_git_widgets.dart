/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/generated/locale_keys.g.dart';
import 'git_config.dart';

class GitAuthorEmail extends StatelessWidget {
  final gitAuthorEmailKey = GlobalKey<FormFieldState<String>>();

  GitAuthorEmail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var gitConfig = Provider.of<GitConfig>(context);

    var saveGitAuthorEmail = (String? gitAuthorEmail) {
      if (gitAuthorEmail == null) return;

      gitConfig.gitAuthorEmail = gitAuthorEmail;
      gitConfig.save();
    };

    return Form(
      child: TextFormField(
        key: gitAuthorEmailKey,
        style: Theme.of(context).textTheme.headline6,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          icon: const Icon(Icons.email),
          hintText: tr(LocaleKeys.settings_email_hint),
          labelText: tr(LocaleKeys.settings_email_label),
        ),
        validator: (String? value) {
          value = value!.trim();
          if (value.isEmpty) {
            return tr(LocaleKeys.settings_email_validator_empty);
          }

          if (!EmailValidator.validate(value)) {
            return tr(LocaleKeys.settings_email_validator_invalid);
          }
          return null;
        },
        textInputAction: TextInputAction.done,
        onFieldSubmitted: saveGitAuthorEmail,
        onSaved: saveGitAuthorEmail,
        initialValue: gitConfig.gitAuthorEmail,
      ),
      onChanged: () {
        if (!gitAuthorEmailKey.currentState!.validate()) return;
        var gitAuthorEmail = gitAuthorEmailKey.currentState!.value;
        saveGitAuthorEmail(gitAuthorEmail);
      },
    );
  }
}

class GitAuthor extends StatelessWidget {
  final gitAuthorKey = GlobalKey<FormFieldState<String>>();

  GitAuthor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var gitConfig = Provider.of<GitConfig>(context);

    var saveGitAuthor = (String? gitAuthor) {
      if (gitAuthor == null) return;
      gitConfig.gitAuthor = gitAuthor;
      gitConfig.save();
    };

    return Form(
      child: TextFormField(
        key: gitAuthorKey,
        style: Theme.of(context).textTheme.headline6,
        decoration: InputDecoration(
          icon: const Icon(Icons.person),
          hintText: tr(LocaleKeys.settings_author_hint),
          labelText: tr(LocaleKeys.settings_author_label),
        ),
        validator: (String? value) {
          value = value!.trim();
          if (value.isEmpty) {
            return tr(LocaleKeys.settings_author_validator);
          }
          return null;
        },
        textInputAction: TextInputAction.done,
        onFieldSubmitted: saveGitAuthor,
        onSaved: saveGitAuthor,
        initialValue: gitConfig.gitAuthor,
      ),
      onChanged: () {
        if (!gitAuthorKey.currentState!.validate()) return;
        var gitAuthor = gitAuthorKey.currentState!.value;
        saveGitAuthor(gitAuthor);
      },
    );
  }
}
