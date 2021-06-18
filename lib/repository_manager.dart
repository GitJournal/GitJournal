import 'dart:io';

import 'package:flutter/material.dart';

import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitjournal/repository.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/utils/logger.dart';

class RepositoryManager with ChangeNotifier {
  var repoIds = <String>[];
  var currentId = DEFAULT_ID;

  late GitJournalRepo _repo;

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

  GitJournalRepo get currentRepo => _repo;

  Future<GitJournalRepo> buildActiveRepository() async {
    var repoCacheDir = p.join(cacheDir, currentId);
    await Directory(repoCacheDir).create(recursive: true);

    _repo = await GitJournalRepo.load(
      gitBaseDir: gitBaseDir,
      cacheDir: repoCacheDir,
      pref: pref,
      id: currentId,
    );

    notifyListeners();
    return _repo;
  }

  String repoFolderName(String id) {
    return pref.getString(id + "_" + FOLDER_NAME_KEY) ?? "journal";
  }

  Future<String> addRepo() async {
    int i = repoIds.length;
    while (repoIds.contains(i.toString())) {
      i++;
    }

    var id = i.toString();
    repoIds.add(id);
    currentId = id;
    await _save();

    // Generate a default folder name!
    await pref.setString(id + "_" + FOLDER_NAME_KEY, "repo_$id");
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
    await buildActiveRepository();
  }

  Future<void> deleteCurrent() async {
    if (repoIds.length == 1) {
      throw Exception("Last Repo cannot be deleted");
    }

    Log.i("Deleting repo: $currentId");

    var i = repoIds.indexOf(currentId);

    var repoPath = _repo.repoPath;
    var cachePath = _repo.cacheDir;

    await Directory(repoPath).delete(recursive: true);
    await Directory(cachePath).delete(recursive: true);

    repoIds.removeAt(i);

    i = i.clamp(0, repoIds.length - 1);
    currentId = repoIds[i];

    await _save();
    await buildActiveRepository();
  }
}
