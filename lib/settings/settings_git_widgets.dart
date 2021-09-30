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
  const GitAuthorEmail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var gitConfig = Provider.of<GitConfig>(context);

    return ListTile(
      title: Text(LocaleKeys.settings_email_label.tr()),
      subtitle: Text(gitConfig.gitAuthorEmail),
      onTap: () async {
        var newEmail = await showDialog(
          context: context,
          builder: (context) => const _GitAuthorEmailDialog(),
        );

        if (newEmail != null && newEmail != gitConfig.gitAuthorEmail) {
          gitConfig.gitAuthorEmail = newEmail;
          gitConfig.save();
        }
      },
    );
  }
}

class _GitAuthorEmailDialog extends StatefulWidget {
  const _GitAuthorEmailDialog({Key? key}) : super(key: key);

  @override
  State<_GitAuthorEmailDialog> createState() => _GitAuthorEmailDialogState();
}

class _GitAuthorEmailDialogState extends State<_GitAuthorEmailDialog> {
  final gitAuthorEmailKey = GlobalKey<FormFieldState<String>>();

  @override
  Widget build(BuildContext context) {
    var gitConfig = Provider.of<GitConfig>(context);
    var isValidEmail = gitAuthorEmailKey.currentState?.isValid;
    var email = gitAuthorEmailKey.currentState?.value;

    var form = TextFormField(
      key: gitAuthorEmailKey,
      keyboardType: TextInputType.emailAddress,
      validator: _validate,
      textInputAction: TextInputAction.done,
      initialValue: gitConfig.gitAuthorEmail,
      autovalidateMode: AutovalidateMode.always,
      onChanged: (_) {
        setState(() {
          // To trigger the isValidEmail check
        });
      },
    );

    return AlertDialog(
      title: Text(LocaleKeys.settings_email_label.tr()),
      content: form,
      actions: <Widget>[
        TextButton(
          child: Text(tr(LocaleKeys.settings_cancel)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text(tr(LocaleKeys.settings_ok)),
          onPressed: isValidEmail == true
              ? () => Navigator.of(context).pop(email)
              : null,
        ),
      ],
    );
  }

  String? _validate(String? value) {
    if (value == null) {
      return tr(LocaleKeys.settings_email_validator_empty);
    }

    value = value.trim();
    if (value.isEmpty) {
      return tr(LocaleKeys.settings_email_validator_empty);
    }

    if (!EmailValidator.validate(value)) {
      return tr(LocaleKeys.settings_email_validator_invalid);
    }
    return null;
  }
}

class GitAuthor extends StatelessWidget {
  final gitAuthorKey = GlobalKey<FormFieldState<String>>();

  GitAuthor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var gitConfig = Provider.of<GitConfig>(context);

    void saveGitAuthor(String? gitAuthor) {
      if (gitAuthor == null) return;
      gitConfig.gitAuthor = gitAuthor;
      gitConfig.save();
    }

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
