/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:core';

import 'package:flutter/foundation.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:git_setup/git_config.dart';
import 'package:git_setup/keygen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/settings/settings_sharedpref.dart';

class GitConfig extends ChangeNotifier
    with SettingsSharedPref
    implements IGitConfig {
  GitConfig(this.id, this.pref);

  @override
  final String id;

  @override
  final SharedPreferences pref;

  @override
  var gitAuthor = "GitJournal";
  @override
  var gitAuthorEmail = "app@gitjournal.io";
  @override
  var sshPublicKey = "";
  @override
  var sshPrivateKey = "";
  @override
  var sshPassword = "";
  @override
  var sshKeyType = SettingsSSHKey.Default.val;

  void load() {
    gitAuthor = getString("gitAuthor") ?? gitAuthor;
    gitAuthorEmail = getString("gitAuthorEmail") ?? gitAuthorEmail;
    sshPublicKey = getString("sshPublicKey") ?? sshPublicKey;
    sshPrivateKey = getString("sshPrivateKey") ?? sshPrivateKey;
    sshPassword = getString("sshPassword") ?? sshPassword;
    sshKeyType = SettingsSSHKey.fromInternalString(getString("sshKeyType")).val;
  }

  @override
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
    await setOption(
      "sshKeyType",
      SettingsSSHKey.fromEnum(sshKeyType),
      SettingsSSHKey.fromEnum(def.sshKeyType),
    );

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

abstract class SettingsOption {
  String toPublicString();
  String toInternalString();

  List<SettingsOption> get allValues;
}

enum SettingsSSHKey implements SettingsOption {
  Ed25519(LocaleKeys.settings_sshKey_ed25519, SshKeyType.Ed25519),
  Rsa(LocaleKeys.settings_sshKey_rsa, SshKeyType.Rsa);

  static const SettingsSSHKey Default = Ed25519;

  final String _publicString;
  final SshKeyType val;
  const SettingsSSHKey(this._publicString, this.val);

  @override
  String toPublicString() => tr(_publicString);
  @override
  String toInternalString() => name;
  @override
  List<SettingsOption> get allValues => values;

  static SettingsSSHKey fromInternalString(String? str) {
    return values.firstWhere(
      (e) => e.toInternalString() == str,
      orElse: () => Default,
    );
  }

  static SettingsSSHKey fromPublicString(String str) {
    return values.firstWhere(
      (e) => e.toPublicString() == str,
      orElse: () => Default,
    );
  }

  static SettingsSSHKey fromEnum(SshKeyType k) {
    return values.firstWhere(
      (e) => e.val == k,
      orElse: () => Default,
    );
  }
}
