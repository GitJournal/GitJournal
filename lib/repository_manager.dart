import 'dart:io';

import 'package:flutter/material.dart';

import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitjournal/repository.dart';
import 'package:gitjournal/settings.dart';

class RepositoryInfo {
  String id;
  String folderName;
  IconData iconData;

  // Add serialization to json / and from
}

// Make this info a change notifier where the current value is ?
// -> things required to create the Repo?
class RepositoryManager with ChangeNotifier {
  List<String> repoIds;
  String currentId;

  Repository _repo;

  final String gitBaseDir;
  final String cacheDir;
  final SharedPreferences pref;

  RepositoryManager({
    @required this.gitBaseDir,
    @required this.cacheDir,
    @required this.pref,
  }) {
    // From the pref load all the RepositoryInfos
  }

  Repository get currentRepo => _repo;

  Future<Repository> buildActiveRepository() async {
    if (_repo != null) {
      return _repo;
    }

    currentId ??= DEFAULT_ID;
    var repoCacheDir = p.join(cacheDir, currentId);
    await Directory(repoCacheDir).create(recursive: true);

    _repo = await Repository.load(
      gitBaseDir: gitBaseDir,
      cacheDir: repoCacheDir,
      pref: pref,
      id: currentId,
    );

    notifyListeners();
    return _repo;
  }

  // call notifyObservers();
  // --> After that what?

  // addRepo(info) -> id
  // removeRepo(id)
  // selectRepo(id)
  // updateRepo(id, info)
}
