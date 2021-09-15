/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitjournal/settings/settings_sharedpref.dart';

class GitConfig extends ChangeNotifier with SettingsSharedPref {
  GitConfig(this.id, this.pref);

  @override
  final String id;

  @override
  final SharedPreferences pref;

  var gitAuthor = "GitJournal";
  var gitAuthorEmail = "app@gitjournal.io";
  var sshPublicKey = "";
  var sshPrivateKey = "";
  var sshPassword = "";

  void load() {
    gitAuthor = getString("gitAuthor") ?? gitAuthor;
    gitAuthorEmail = getString("gitAuthorEmail") ?? gitAuthorEmail;
    sshPublicKey = getString("sshPublicKey") ?? sshPublicKey;
    sshPrivateKey = getString("sshPrivateKey") ?? sshPrivateKey;
    sshPassword = getString("sshPassword") ?? sshPassword;
  }

  Future<void> save() async {
    var def = GitConfig(id, pref);
    // I could call _load and get all the values
    // and then compare it.
    // why am I doing this? - I'm not sure

    await setString("gitAuthor", gitAuthor, def.gitAuthor);
    await setString("gitAuthorEmail", gitAuthorEmail, def.gitAuthorEmail);
    await setString("sshPublicKey", sshPublicKey, def.sshPublicKey);
    await setString("sshPrivateKey", sshPrivateKey, def.sshPrivateKey);
    await setString("sshPassword", sshPassword, def.sshPassword);

    notifyListeners();
  }

  Map<String, String> toLoggableMap() {
    return <String, String>{
      "gitAuthor": gitAuthor.isNotEmpty.toString(),
      "gitAuthorEmail": gitAuthorEmail.isNotEmpty.toString(),
      'sshPublicKey': sshPublicKey.isNotEmpty.toString(),
      'sshPrivateKey': sshPrivateKey.isNotEmpty.toString(),
      'sshPassword': sshPassword.isNotEmpty.toString(),
    };
  }
}

// 1. Make sure we don't need to set the value and call save
// 2. Less calls to setString so this is much faster

// Optimizing this doesn't matter
