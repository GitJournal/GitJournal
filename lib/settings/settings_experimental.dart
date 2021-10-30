/*
 * SPDX-FileCopyrightText: 2020-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:crypto/crypto.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/settings/app_config.dart';

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
    var appConfig = Provider.of<AppConfig>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(LocaleKeys.settings_experimental_title)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Scrollbar(
        child: ListView(
          children: <Widget>[
            const Center(
              child: Icon(CommunityMaterialIcons.flask, size: 64 * 2),
            ),
            const Divider(),
            SwitchListTile(
              title:
                  Text(tr(LocaleKeys.settings_experimental_includeSubfolders)),
              value: appConfig.experimentalSubfolders,
              onChanged: (bool newVal) {
                appConfig.experimentalSubfolders = newVal;
                appConfig.save();
                setState(() {});
              },
            ),
            SwitchListTile(
              title: Text(tr(LocaleKeys.settings_experimental_graphView)),
              value: appConfig.experimentalGraphView,
              onChanged: (bool newVal) {
                appConfig.experimentalGraphView = newVal;
                appConfig.save();
                setState(() {});
              },
            ),
            SwitchListTile(
              title: Text(tr(LocaleKeys.settings_experimental_markdownToolbar)),
              value: appConfig.experimentalMarkdownToolbar,
              onChanged: (bool newVal) {
                appConfig.experimentalMarkdownToolbar = newVal;
                appConfig.save();
                setState(() {});
              },
            ),
            SwitchListTile(
              title: Text(tr(LocaleKeys.settings_experimental_accounts)),
              value: appConfig.experimentalAccounts,
              onChanged: (bool newVal) {
                appConfig.experimentalAccounts = newVal;
                appConfig.save();
                setState(() {});
              },
            ),
            SwitchListTile(
              title: Text(tr(LocaleKeys.settings_experimental_merge)),
              value: appConfig.experimentalGitMerge,
              onChanged: (bool newVal) {
                appConfig.experimentalGitMerge = newVal;
                appConfig.save();
                setState(() {});
              },
            ),
            SwitchListTile(
              title:
                  Text(tr(LocaleKeys.settings_experimental_experimentalGitOps)),
              value: appConfig.experimentalGitOps,
              onChanged: (bool newVal) {
                appConfig.experimentalGitOps = newVal;
                appConfig.save();
                setState(() {});
              },
            ),
            SwitchListTile(
              title:
                  Text(tr(LocaleKeys.settings_experimental_autoCompleteTags)),
              value: appConfig.experimentalTagAutoCompletion,
              onChanged: (bool newVal) {
                appConfig.experimentalTagAutoCompletion = newVal;
                appConfig.save();
                setState(() {});
              },
            ),
            SwitchListTile(
              title: Text(tr(LocaleKeys.settings_experimental_history)),
              value: appConfig.experimentalHistory,
              onChanged: (bool newVal) {
                appConfig.experimentalHistory = newVal;
                appConfig.save();
                setState(() {});
              },
            ),
            ListTile(
              title: const Text('Enter Pro Password'),
              subtitle: Text('Pro: ' + AppConfig.instance.proMode.toString()),
              onTap: () async {
                var _ = await showDialog(
                  context: context,
                  builder: (context) => _PasswordForm(),
                );
                setState(() {});
              },
            ),
          ],
          padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
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
        style: Theme.of(context).textTheme.headline6,
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
          appConfig.proMode = true;
          appConfig.validateProMode = false;
          appConfig.proExpirationDate = '2050-01-01';
          appConfig.save();
        },
      ),
      actions: <Widget>[
        TextButton(
          child: Text(tr(LocaleKeys.settings_ok)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}
