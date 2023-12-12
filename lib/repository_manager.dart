/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/settings/storage_config.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

class RepositoryManager with ChangeNotifier {
  var repoIds = <String>[];
  var currentId = DEFAULT_ID;

  GitJournalRepo? _repo;
  Object? _repoError;

  final String gitBaseDir;
  final String cacheDir;
  final SharedPreferences pref;

  RepositoryManager({
    required this.gitBaseDir,
    required this.cacheDir,
    required this.pref,
  }) {
    _load();
    Log.i("Repo Ids $repoIds");
    Log.i("Current Id $currentId");
  }

  GitJournalRepo? get currentRepo => _repo;
  Object? get currentRepoError => _repoError;

  Future<GitJournalRepo?> buildActiveRepository({
    bool loadFromCache = false, // LB: `false` seems to shave 2 seconds off startup.
    bool syncOnBoot = true,
  }) async {
    var repoCacheDir = p.join(cacheDir, currentId);

    _repo = null;
    _repoError = null;
    notifyListeners();

    try {
      _repo = await GitJournalRepo.load(
        repoManager: this,
        gitBaseDir: gitBaseDir,
        cacheDir: repoCacheDir,
        pref: pref,
        id: currentId,
        loadFromCache: loadFromCache,
        syncOnBoot: syncOnBoot,
      );
    } catch (ex, st) {
      Log.e("buildActiveRepo", ex: ex, stacktrace: st);
      _repoError = ex;
      notifyListeners();
      return null;
    }

    notifyListeners();
    return _repo!;
  }

  String repoFolderName(String id) {
    return pref.getString("${id}_$FOLDER_NAME_KEY") ?? "journal";
  }

  Future<String> addRepoAndSwitch() async {
    int i = repoIds.length;
    while (repoIds.contains(i.toString())) {
      i++;
    }

    var id = i.toString();
    repoIds.add(id);
    currentId = id;
    await _save();

    // Generate a default folder name!
    await pref.setString("${id}_$FOLDER_NAME_KEY", "repo_$id");
    Log.i("Creating new repo with id: $id and folder: repo_$id");

    await buildActiveRepository();
    return id;
  }

  Future<void> _save() async {
    await pref.setString("activeRepo", currentId);
    await pref.setStringList("gitRepos", repoIds);
  }

  void _load() {
    currentId = pref.getString("activeRepo") ?? DEFAULT_ID;
    repoIds = pref.getStringList("gitRepos") ?? [DEFAULT_ID];
  }

  Future<void> setCurrentRepo(String id) async {
    assert(repoIds.contains(id));
    currentId = id;
    await _save();

    Log.i("Switching to repo with id: $id");
    buildActiveRepository();
  }

  Future<void> deleteCurrent() async {
    Log.i("Deleting repo: $currentId");

    var i = repoIds.indexOf(currentId);
    await _repo?.delete();
    repoIds.removeAt(i);

    if (repoIds.isEmpty) {
      await addRepoAndSwitch();
      return;
    }

    i = i.clamp(0, repoIds.length - 1);
    currentId = repoIds[i];

    await _save();
    await buildActiveRepository();
  }

  // Not sure when to call this!
  Future<void> cleanupInvalidRepos() async {
    var invalidIds = <String>[];
    for (var id in repoIds) {
      var exists = await GitJournalRepo.exists(
          gitBaseDir: gitBaseDir, pref: pref, id: id);
      if (!exists) {
        invalidIds.add(id);
      }
    }

    repoIds.removeWhere((id) => invalidIds.contains(id));
    notifyListeners();
    return _save();
  }
}
