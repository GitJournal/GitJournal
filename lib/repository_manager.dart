/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/settings/storage_config.dart';
import 'package:gitjournal/utils/result.dart';

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

  Future<Result<GitJournalRepo>> buildActiveRepository({
    bool loadFromCache = true,
    bool syncOnBoot = true,
  }) async {
    var repoCacheDir = p.join(cacheDir, currentId);

    _repo = null;
    _repoError = null;
    notifyListeners();

    var r = await GitJournalRepo.load(
      repoManager: this,
      gitBaseDir: gitBaseDir,
      cacheDir: repoCacheDir,
      pref: pref,
      id: currentId,
      loadFromCache: loadFromCache,
      syncOnBoot: syncOnBoot,
    );
    if (r.isFailure) {
      Log.e("buildActiveRepo", result: r);
      _repoError = r.error;
      return fail(r);
    }

    _repo = r.getOrThrow();

    notifyListeners();
    return Result(_repo!);
  }

  String repoFolderName(String id) {
    return pref.getString(id + "_" + FOLDER_NAME_KEY) ?? "journal";
  }

  Future<Result<String>> addRepoAndSwitch() async {
    int i = repoIds.length;
    while (repoIds.contains(i.toString())) {
      i++;
    }

    var id = i.toString();
    repoIds.add(id);
    currentId = id;
    await _save();

    dynamic _;

    // Generate a default folder name!
    _ = await pref.setString(id + "_" + FOLDER_NAME_KEY, "repo_$id");
    Log.i("Creating new repo with id: $id and folder: repo_$id");

    var r = await buildActiveRepository();
    if (r.isFailure) {
      return fail(r);
    }

    return Result(id);
  }

  Future<void> _save() async {
    dynamic _;
    _ = await pref.setString("activeRepo", currentId);
    _ = await pref.setStringList("gitRepos", repoIds);
  }

  void _load() {
    currentId = pref.getString("activeRepo") ?? DEFAULT_ID;
    repoIds = pref.getStringList("gitRepos") ?? [DEFAULT_ID];
  }

  Future<Result<void>> setCurrentRepo(String id) async {
    assert(repoIds.contains(id));
    currentId = id;
    await _save();

    Log.i("Switching to repo with id: $id");
    return buildActiveRepository();
  }

  Future<void> deleteCurrent() async {
    Log.i("Deleting repo: $currentId");
    dynamic _;

    var i = repoIds.indexOf(currentId);
    await _repo?.delete();
    _ = repoIds.removeAt(i);

    if (repoIds.isEmpty) {
      _ = await addRepoAndSwitch();
      return;
    }

    i = i.clamp(0, repoIds.length - 1);
    currentId = repoIds[i];

    await _save();
    _ = await buildActiveRepository();
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
