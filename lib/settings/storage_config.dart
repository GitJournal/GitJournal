import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

import 'package:icloud_documents_path/icloud_documents_path.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitjournal/settings/settings_sharedpref.dart';

const FOLDER_NAME_KEY = "remoteGitRepoPath";

class StorageConfig extends ChangeNotifier with SettingsSharedPref {
  StorageConfig(this.id);

  @override
  final String id;

  var folderName = "journal";
  var storeInternally = true;
  var storageLocation = "";

  void load(SharedPreferences pref) {
    folderName = getString(pref, FOLDER_NAME_KEY) ?? folderName;
    storeInternally = getBool(pref, "storeInternally") ?? storeInternally;
    storageLocation = getString(pref, "storageLocation") ?? "";
  }

  Future<void> save() async {
    var pref = await SharedPreferences.getInstance();
    var defaultSet = StorageConfig(id);

    await setString(pref, FOLDER_NAME_KEY, folderName, defaultSet.folderName);
    await setBool(
        pref, "storeInternally", storeInternally, defaultSet.storeInternally);
    await setString(
        pref, "storageLocation", storageLocation, defaultSet.storageLocation);
  }

  Map<String, String> toLoggableMap() {
    return <String, String>{
      'folderName': folderName.toString(),
      'storeInternally': storeInternally.toString(),
      'storageLocation': storageLocation,
    };
  }

  Future<String> buildRepoPath(String internalDir) async {
    if (storeInternally) {
      return p.join(internalDir, folderName);
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
      return p.join(basePath, folderName);
    }

    return p.join(storageLocation, folderName);
  }
}
