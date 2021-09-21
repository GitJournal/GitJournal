/*
 * SPDX-FileCopyrightText: 2020-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:crypto/crypto.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/settings/app_settings.dart';

class ExperimentalSettingsScreen extends StatefulWidget {
  @override
  _ExperimentalSettingsScreenState createState() =>
      _ExperimentalSettingsScreenState();
}

class _ExperimentalSettingsScreenState
    extends State<ExperimentalSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    var appSettings = Provider.of<AppSettings>(context);

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
            SwitchListTile(
              title:
                  Text(tr(LocaleKeys.settings_experimental_includeSubfolders)),
              value: appSettings.experimentalSubfolders,
              onChanged: (bool newVal) {
                appSettings.experimentalSubfolders = newVal;
                appSettings.save();
                setState(() {});
              },
            ),
            SwitchListTile(
              title: Text(tr(LocaleKeys.settings_experimental_graphView)),
              value: appSettings.experimentalGraphView,
              onChanged: (bool newVal) {
                appSettings.experimentalGraphView = newVal;
                appSettings.save();
                setState(() {});
              },
            ),
            SwitchListTile(
              title: Text(tr(LocaleKeys.settings_experimental_markdownToolbar)),
              value: appSettings.experimentalMarkdownToolbar,
              onChanged: (bool newVal) {
                appSettings.experimentalMarkdownToolbar = newVal;
                appSettings.save();
                setState(() {});
              },
            ),
            SwitchListTile(
              title: Text(tr(LocaleKeys.settings_experimental_accounts)),
              value: appSettings.experimentalAccounts,
              onChanged: (bool newVal) {
                appSettings.experimentalAccounts = newVal;
                appSettings.save();
                setState(() {});
              },
            ),
            SwitchListTile(
              title: Text(tr(LocaleKeys.settings_experimental_merge)),
              value: appSettings.experimentalGitMerge,
              onChanged: (bool newVal) {
                appSettings.experimentalGitMerge = newVal;
                appSettings.save();
                setState(() {});
              },
            ),
            SwitchListTile(
              title:
                  Text(tr(LocaleKeys.settings_experimental_experimentalGitOps)),
              value: appSettings.experimentalGitOps,
              onChanged: (bool newVal) {
                appSettings.experimentalGitOps = newVal;
                appSettings.save();
                setState(() {});
              },
            ),
            SwitchListTile(
              title:
                  Text(tr(LocaleKeys.settings_experimental_autoCompleteTags)),
              value: appSettings.experimentalTagAutoCompletion,
              onChanged: (bool newVal) {
                appSettings.experimentalTagAutoCompletion = newVal;
                appSettings.save();
                setState(() {});
              },
            ),
            ListTile(
              title: const Text('Enter Pro Password'),
              subtitle: Text('Pro: ' + AppSettings.instance.proMode.toString()),
              onTap: () async {
                await showDialog(
                  context: context,
                  builder: (context) => _PasswordForm(),
                );
                setState(() {});
                print('Changing State');
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
          print(sha1Digest);

          if (sha1Digest.toString() !=
              '27538d8231e49655fd1c26c7b8495c2c870c741b') {
            return;
          }

          print('Unlocking Pro Mode');

          var appSettings = AppSettings.instance;
          appSettings.proMode = true;
          appSettings.validateProMode = false;
          appSettings.proExpirationDate = '2050-01-01';
          appSettings.save();
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
