/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:gitjournal/app_localizations_context.dart';
import 'package:provider/provider.dart';

import 'git_config.dart';

class GitAuthorEmail extends StatelessWidget {
  const GitAuthorEmail({super.key});

  @override
  Widget build(BuildContext context) {
    var gitConfig = Provider.of<GitConfig>(context);

    return ListTile(
      title: Text(context.loc.settingsEmailLabel),
      subtitle: Text(gitConfig.gitAuthorEmail),
      onTap: () async {
        var newEmail = await showDialog(
          context: context,
          builder: (context) => const _GitAuthorEmailDialog(),
        );

        if (newEmail != null && newEmail != gitConfig.gitAuthorEmail) {
          gitConfig.gitAuthorEmail = newEmail;
          await gitConfig.save();
        }
      },
    );
  }
}

class _GitAuthorEmailDialog extends StatefulWidget {
  const _GitAuthorEmailDialog();

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
      title: Text(context.loc.settingsEmailLabel),
      content: form,
      actions: <Widget>[
        TextButton(
          child: Text(context.loc.settingsCancel),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text(context.loc.settingsOk),
          onPressed: isValidEmail == true
              ? () => Navigator.of(context).pop(email)
              : null,
        ),
      ],
    );
  }

  String? _validate(String? value) {
    if (value == null) {
      return context.loc.settingsEmailValidatorEmpty;
    }

    value = value.trim();
    if (value.isEmpty) {
      return context.loc.settingsEmailValidatorEmpty;
    }

    if (!EmailValidator.validate(value)) {
      return context.loc.settingsEmailValidatorInvalid;
    }
    return null;
  }
}

class GitAuthor extends StatelessWidget {
  const GitAuthor({super.key});

  @override
  Widget build(BuildContext context) {
    var gitConfig = Provider.of<GitConfig>(context);

    return ListTile(
      title: Text(context.loc.settingsAuthorLabel),
      subtitle: Text(gitConfig.gitAuthor),
      onTap: () async {
        var newName = await showDialog(
          context: context,
          builder: (context) => const _GitAuthorDialog(),
        );

        if (newName != null && newName != gitConfig.gitAuthor) {
          gitConfig.gitAuthor = newName;
          await gitConfig.save();
        }
      },
    );
  }
}

class _GitAuthorDialog extends StatefulWidget {
  const _GitAuthorDialog();

  @override
  __GitAuthorDialogState createState() => __GitAuthorDialogState();
}

class __GitAuthorDialogState extends State<_GitAuthorDialog> {
  final gitAuthorKey = GlobalKey<FormFieldState<String>>();

  @override
  Widget build(BuildContext context) {
    var gitConfig = Provider.of<GitConfig>(context);
    var isValid = gitAuthorKey.currentState?.isValid;
    var author = gitAuthorKey.currentState?.value;

    var form = TextFormField(
      key: gitAuthorKey,
      keyboardType: TextInputType.name,
      validator: (String? value) {
        value = value!.trim();
        if (value.isEmpty) {
          return context.loc.settingsAuthorValidator;
        }
        return null;
      },
      textInputAction: TextInputAction.done,
      initialValue: gitConfig.gitAuthor,
      autovalidateMode: AutovalidateMode.always,
      onChanged: (_) {
        setState(() {
          // To trigger the isValid check
        });
      },
    );

    return AlertDialog(
      title: Text(context.loc.settingsAuthorLabel),
      content: form,
      actions: <Widget>[
        TextButton(
          child: Text(context.loc.settingsCancel),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text(context.loc.settingsOk),
          onPressed:
              isValid == true ? () => Navigator.of(context).pop(author) : null,
        ),
      ],
    );
  }
}
