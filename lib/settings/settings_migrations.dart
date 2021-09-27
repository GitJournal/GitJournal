/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart';

import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/settings/settings.dart';

Future<void> migrateSettings(
  String id,
  SharedPreferences pref,
  String gitBaseDir,
) async {
  var version = pref.getInt('settingsVersion') ?? -1;
  dynamic _;

  if (version == 0) {
    Log.i("Migrating settings from v0 -> v1");
    var cache = p.join(gitBaseDir, "cache.json");
    if (File(cache).existsSync()) {
      var _ = await File(cache).delete();
    }

    var localGitRepoConfigured =
        pref.getBool("localGitRepoConfigured") ?? false;
    var remoteGitRepoConfigured =
        pref.getBool("remoteGitRepoConfigured") ?? false;

    if (localGitRepoConfigured && !remoteGitRepoConfigured) {
      Log.i("Migrating from local and remote repos to a single one");
      var oldName = p.join(gitBaseDir, "journal_local");
      var newName = p.join(gitBaseDir, "journal");

      if (Directory(oldName).existsSync()) {
        var _ = await Directory(oldName).rename(newName);
        var folderName = "journal";

        var __ = await pref.setString('remoteGitRepoPath', folderName);
      }
    }

    var oldDir = Directory(p.join(gitBaseDir, '../files'));
    if (oldDir.existsSync()) {
      // Move everything from the old dir
      var stream = await (oldDir.list().toList());
      for (var fsEntity in stream) {
        var stat = await fsEntity.stat();
        if (stat.type != FileSystemEntityType.directory) {
          var fileName = p.basename(fsEntity.path);
          if (fileName == 'cache.json') {
            var _ = await File(fsEntity.path).delete();
          }
          continue;
        }

        var folderName = p.basename(fsEntity.path);
        if (folderName.startsWith('journal') || folderName.startsWith('ssh')) {
          var newPath = p.join(gitBaseDir, folderName);
          if (!Directory(newPath).existsSync()) {
            var _ = await Directory(fsEntity.path).rename(newPath);
          }
        }
      }
    }

    // Save the ssh keys
    await migrateSshKeys(pref, gitBaseDir);

    version = 1;
    var _ = await pref.setInt("settingsVersion", version);
  }

  if (version == 1) {
    Log.i("Migrating settings from v1 -> v2");
    var prefix = "${DEFAULT_ID}_";

    var stringKeys = [
      'gitAuthor',
      'gitAuthorEmail',
      'noteFileNameFormat',
      'journalNoteFileNameFormat',
      'yamlModifiedKey',
      'yamlCreatedKey',
      'yamlTagsKey',
      'customMetaData',
      'defaultNewNoteFolderSpec',
      'journalEditordefaultNewNoteFolderSpec',
      'remoteSyncFrequency',
      'sortingField',
      'sortingOrder',
      'defaultEditor',
      'defaultView',
      'markdownDefaultView',
      'markdownLastUsedView',
      'folderViewHeaderType',
      'homeScreen',
      'imageLocationSpec',
      'remoteGitRepoPath',
      'sshPublicKey',
      'sshPrivateKey',
      'sshPassword',
      'storageLocation',
    ];
    for (var key in stringKeys) {
      var value = pref.getString(key);
      if (value != null) {
        _ = await pref.remove(key);
        _ = await pref.setString(prefix + key, value);
      }
    }

    var boolKeys = [
      'yamlHeaderEnabled',
      'journalEditorSingleNote',
      'showNoteSummary',
      'emojiParser',
      'zenMode',
      'saveTitleInH1',
      'swipeToDelete',
      'bottomMenuBar',
      'storeInternally',
    ];
    for (var key in boolKeys) {
      var value = pref.getBool(key);
      if (value != null) {
        _ = await pref.remove(key);
        _ = await pref.setBool(prefix + key, value);
      }
    }

    var stringListKeys = [
      'inlineTagPrefixes',
    ];
    for (var key in stringListKeys) {
      var value = pref.getStringList(key);
      if (value != null) {
        _ = await pref.remove(key);
        _ = await pref.setStringList(prefix + key, value);
      }
    }

    version = 2;
    _ = await pref.remove("settingsVersion");
    _ = await pref.setInt(prefix + "settingsVersion", version);
  }

  if (version == 2) {
    var saveTitleInH1 = pref.getBool(id + '_' + "saveTitleInH1");
    if (saveTitleInH1 == false) {
      var key = id + "_" + "titleSettings";
      _ = await pref.setString(key, "yaml");
    }

    version = 3;
  }
}

Future<void> migrateSshKeys(
  SharedPreferences pref,
  String gitBaseDir, {
  String prefix = "",
}) async {
  // Save the ssh keys
  var oldSshDir = Directory(p.join(gitBaseDir, '../files/ssh'));
  if (oldSshDir.existsSync()) {
    await migrateSshKeysFromDir(pref, oldSshDir, prefix: prefix);
  }

  var newSshDir = Directory(p.join(gitBaseDir, 'ssh'));
  if (newSshDir.existsSync()) {
    await migrateSshKeysFromDir(pref, newSshDir, prefix: prefix);
  }
}

Future<void> migrateSshKeysFromDir(
  SharedPreferences pref,
  Directory dir, {
  String prefix = "",
}) async {
  dynamic _;
  var sshPublicKeyPath = p.join(dir.path, "id_rsa.pub");
  var sshPrivateKeyPath = p.join(dir.path, "id_rsa");

  var publicKeyExists = File(sshPublicKeyPath).existsSync();
  var privateKeyExists = File(sshPrivateKeyPath).existsSync();
  if (publicKeyExists && privateKeyExists) {
    var sshPublicKey = await File(sshPublicKeyPath).readAsString();
    var sshPrivateKey = await File(sshPrivateKeyPath).readAsString();

    _ = await pref.setString(prefix + "sshPublicKey", sshPublicKey);
    _ = await pref.setString(prefix + "sshPrivateKey", sshPrivateKey);
    _ = await pref.setString(prefix + "sshPassword", "");
  }
}
