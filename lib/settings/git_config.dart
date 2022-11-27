/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:core';

import 'package:flutter/widgets.dart';
import 'package:git_setup/git_config.dart';
import 'package:git_setup/keygen.dart';
import 'package:gitjournal/core/folder/sorting_mode.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/settings/settings_sharedpref.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  var sshKeyType = SettingsSSHKey.Default.toEnum();

  void load() {
    gitAuthor = getString("gitAuthor") ?? gitAuthor;
    gitAuthorEmail = getString("gitAuthorEmail") ?? gitAuthorEmail;
    sshPublicKey = getString("sshPublicKey") ?? sshPublicKey;
    sshPrivateKey = getString("sshPrivateKey") ?? sshPrivateKey;
    sshPassword = getString("sshPassword") ?? sshPassword;
    sshKeyType =
        SettingsSSHKey.fromInternalString(getString("sshKeyType")).toEnum();
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
    await setString(
      "sshKeyType",
      SettingsSSHKey.fromEnum(sshKeyType).toInternalString(),
      SettingsSSHKey.fromEnum(def.sshKeyType).toInternalString(),
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

class SettingsSSHKey extends GjSetting {
  static const Ed25519 = SettingsSSHKey(Lk.settingsSshKeyEd25519, "Ed25519");
  static const Rsa = SettingsSSHKey(Lk.settingsSshKeyRsa, "Rsa");
  static const Default = Ed25519;

  const SettingsSSHKey(super.lk, super.str);

  static const options = [
    Ed25519,
    Rsa,
  ];

  static SettingsSSHKey fromInternalString(String? str) =>
      GjSetting.fromInternalString(options, Default, str) as SettingsSSHKey;

  static SettingsSSHKey fromPublicString(BuildContext context, String str) =>
      GjSetting.fromPublicString(context, options, Default, str)
          as SettingsSSHKey;

  static SettingsSSHKey fromEnum(SshKeyType k) {
    switch (k) {
      case SshKeyType.Rsa:
        return Rsa;
      case SshKeyType.Ed25519:
        return Ed25519;
    }
  }

  SshKeyType toEnum() {
    switch (this) {
      case Ed25519:
        return SshKeyType.Ed25519;
      case Rsa:
        return SshKeyType.Rsa;
      default:
        assert(false, "SshKeyType mismatch");
        return SshKeyType.Ed25519;
    }
  }
}
