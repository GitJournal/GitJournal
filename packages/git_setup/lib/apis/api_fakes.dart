/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:convert';

import 'githost.dart';
import 'github.dart';

typedef JsonMap = Map<String, dynamic>;
typedef JsonList = List<JsonMap>;

class GitHubFake implements GitHost {
  String data;
  GitHubFake(this.data);

  @override
  void init(OAuthCallback oAuthCallback) {}
  @override
  Future<void> launchOAuthScreen() async {}

  @override
  Future<UserInfo> getUserInfo() async {
    throw Exception("Not Implemented");
  }

  @override
  Future<void> addDeployKey(String sshPublicKey, String repoFullName) async {
    throw Exception("Not Implemented");
  }

  @override
  Future<GitHostRepo> createRepo(String name) async {
    throw Exception("Not Implemented");
  }

  @override
  Future<GitHostRepo> getRepo(String name) async {
    throw Exception("Not Implemented");
  }

  @override
  Future<List<GitHostRepo>> listRepos() async {
    List<dynamic> list = jsonDecode(data);
    var repos = <GitHostRepo>[];
    for (var d in list) {
      var map = Map<String, dynamic>.from(d);
      var repo = GitHub.repoFromJson(map);
      repos.add(repo);
    }

    return repos;
  }
}
