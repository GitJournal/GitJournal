import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitjournal/settings/settings_sharedpref.dart';

class GitConfig extends ChangeNotifier with SettingsSharedPref {
  GitConfig(this.id);

  @override
  final String id;

  var gitAuthor = "GitJournal";
  var gitAuthorEmail = "app@gitjournal.io";
  var sshPublicKey = "";
  var sshPrivateKey = "";
  var sshPassword = "";

  void load(SharedPreferences pref) {
    gitAuthor = getString(pref, "gitAuthor") ?? gitAuthor;
    gitAuthorEmail = getString(pref, "gitAuthorEmail") ?? gitAuthorEmail;
    sshPublicKey = getString(pref, "sshPublicKey") ?? sshPublicKey;
    sshPrivateKey = getString(pref, "sshPrivateKey") ?? sshPrivateKey;
    sshPassword = getString(pref, "sshPassword") ?? sshPassword;
  }

  Future<void> save() async {
    var pref = await SharedPreferences.getInstance();
    var defaultSet = GitConfig(id);

    await setString(pref, "gitAuthor", gitAuthor, defaultSet.gitAuthor);
    await setString(
        pref, "gitAuthorEmail", gitAuthorEmail, defaultSet.gitAuthorEmail);
    await setString(
        pref, "sshPublicKey", sshPublicKey, defaultSet.sshPublicKey);
    await setString(
        pref, "sshPrivateKey", sshPrivateKey, defaultSet.sshPrivateKey);
    await setString(pref, "sshPassword", sshPassword, defaultSet.sshPassword);
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
