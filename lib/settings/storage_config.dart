/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/foundation.dart';

import 'package:icloud_documents_path/icloud_documents_path.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart' show Platform;

import 'package:gitjournal/settings/settings_sharedpref.dart';

const FOLDER_NAME_KEY = "remoteGitRepoPath";

class StorageConfig extends ChangeNotifier with SettingsSharedPref {
  StorageConfig(this.id, this.pref);

  @override
  final String id;

  @override
  final SharedPreferences pref;

  var folderName = "journal";
  var storeInternally = true;
  var storageLocation = "";

  void load() {
    folderName = getString(FOLDER_NAME_KEY) ?? folderName;
    storeInternally = getBool("storeInternally") ?? storeInternally;
    storageLocation = getString("storageLocation") ?? "";
  }

  Future<void> save() async {
    var def = StorageConfig(id, pref);

    await setString(FOLDER_NAME_KEY, folderName, def.folderName);
    await setBool("storeInternally", storeInternally, def.storeInternally);
    await setString("storageLocation", storageLocation, def.storageLocation);

    notifyListeners();
  }

  Map<String, String> toLoggableMap() {
    if (kReleaseMode) {
      var isDefault = folderName == StorageConfig(id, pref).folderName;
      return <String, String>{
        'folderName': isDefault ? 'default' : 'other',
        'storeInternally': storeInternally.toString(),
        'storageLocation': storageLocation,
      };
    }

    return <String, String>{
      'folderName': folderName.toString(),
      'storeInternally': storeInternally.toString(),
      'storageLocation': storageLocation,
    };
  }

  Future<String> buildRepoPath(String internalDir) async {
    if (storeInternally) {
      var repoPath = p.join(internalDir, folderName);
      return repoPath.endsWith(p.separator) ? repoPath : repoPath + p.separator;
    }
    if (Platform.isIOS) {
      //
      // iOS is strange as fuck and it seems if you don't call this function
      // asking for the path, you won't be able to access the path
      // So even though we have it stored in the settings, this method
      // must be called
      //
      var basePath = await ICloudDocumentsPath.documentsPath;
      if (basePath == null) {
        // Go back to the normal path
        return p.join(storageLocation, folderName);
      }
      assert(basePath == storageLocation);
      var repoPath = p.join(basePath, folderName);
      return repoPath.endsWith(p.separator) ? repoPath : repoPath + p.separator;
    }

    var repoPath = p.join(storageLocation, folderName);
    return repoPath.endsWith(p.separator) ? repoPath : repoPath + p.separator;
  }
}
