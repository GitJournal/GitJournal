/*
 * SPDX-FileCopyrightText: 2020-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'dart:convert';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/settings/app_config.dart';
import 'package:provider/provider.dart';

class ExperimentalSettingsScreen extends StatefulWidget {
  static const routePath = '/settings/experimental';

  @override
  _ExperimentalSettingsScreenState createState() =>
      _ExperimentalSettingsScreenState();
}

class _ExperimentalSettingsScreenState
    extends State<ExperimentalSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    var appConfig = context.watch<AppConfig>();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.settingsExperimentalTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Scrollbar(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
          children: <Widget>[
            const Center(
              child: Icon(CommunityMaterialIcons.flask, size: 64 * 2),
            ),
            const Divider(),
            SwitchListTile(
              title: Text(context.loc.settingsExperimentalIncludeSubfolders),
              value: appConfig.experimentalSubfolders,
              onChanged: (bool newVal) {
                appConfig.experimentalSubfolders = newVal;
                appConfig.save();
                setState(() {});
              },
            ),
            SwitchListTile(
              title: Text(context.loc.settingsExperimentalMarkdownToolbar),
              value: appConfig.experimentalMarkdownToolbar,
              onChanged: (bool newVal) {
                appConfig.experimentalMarkdownToolbar = newVal;
                appConfig.save();
                setState(() {});
              },
            ),
            SwitchListTile(
              title: Text(context.loc.settingsExperimentalAccounts),
              value: appConfig.experimentalAccounts,
              onChanged: (bool newVal) {
                appConfig.experimentalAccounts = newVal;
                appConfig.save();
                setState(() {});
              },
            ),
            SwitchListTile(
              title: Text(context.loc.settingsExperimentalAutoCompleteTags),
              value: appConfig.experimentalTagAutoCompletion,
              onChanged: (bool newVal) {
                appConfig.experimentalTagAutoCompletion = newVal;
                appConfig.save();
                setState(() {});
              },
            ),
            ListTile(
              title: const Text('Enter Pro Password'),
              subtitle: Text('Pro: ${AppConfig.instance.proMode}'),
              onTap: () async {
                await showDialog(
                  context: context,
                  builder: (context) => _PasswordForm(),
                );
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Pro Password'),
      content: TextField(
        style: Theme.of(context).textTheme.titleLarge,
        decoration: const InputDecoration(
          icon: Icon(Icons.security_rounded),
          hintText: 'Enter Password',
          labelText: 'Password',
        ),
        onChanged: (String value) {
          value = value.trim();
          if (value.isEmpty) {
            return;
          }

          const salt = 'randomSaltGitJournal';
          var sha1Digest = sha1.convert(utf8.encode(value + salt));

          if (sha1Digest.toString() !=
              '27538d8231e49655fd1c26c7b8495c2c870c741b') {
            Log.e("Pro Password Incorrect");
            return;
          }

          Log.i('Unlocking Pro Mode');

          var appConfig = AppConfig.instance;
          appConfig.validateProMode = false;
          appConfig.proMode = true;
          appConfig.save();
        },
      ),
      actions: <Widget>[
        TextButton(
          child: Text(context.loc.settingsOk),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}
