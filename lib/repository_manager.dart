import 'dart:io';

import 'package:flutter/material.dart';

import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitjournal/repository.dart';
import 'package:gitjournal/settings.dart';

class RepositoryInfo {
  String id;
  String folderName;
  // IconData iconData;

  RepositoryInfo.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    folderName = map['folderName'];
    // iconData = IconData(map['iconData'] as int);
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'folderName': folderName,
        // 'iconData': iconData.codePoint,
      };
}

// Make this info a change notifier where the current value is ?
// -> things required to create the Repo?
class RepositoryManager with ChangeNotifier {
  List<String> repoIds;
  String currentId;

  GitJournalRepo _repo;
  RepositoryInfo _repoInfo;

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

  GitJournalRepo get currentRepo => _repo;
  RepositoryInfo get currentRepoInfo => _repoInfo;

  Future<GitJournalRepo> buildActiveRepository() async {
    if (_repo != null) {
      return _repo;
    }

    currentId ??= DEFAULT_ID;
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

  Future<void> buildRepoInfoList() async {
    // Add the latest folder, sort
    // No need to do anything else
  }

  // call notifyObservers();
  // --> After that what?

  // addRepo(info) -> id
  // removeRepo(id)
  // selectRepo(id)
  // updateRepo(id, info)
}
