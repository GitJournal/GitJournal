import 'dart:convert';

import 'package:gitjournal/apis/githost.dart';
import 'package:gitjournal/apis/github.dart';

typedef JsonMap = Map<String, dynamic>;
typedef JsonList = List<JsonMap>;

class GitHubFake implements GitHost {
  String data;
  GitHubFake(this.data);

  @override
  void init(OAuthCallback oAuthCallback) {}
  @override
  Future launchOAuthScreen() async {}

  @override
  Future<UserInfo?> getUserInfo() async {}
  @override
  Future addDeployKey(String sshPublicKey, String repoFullName) async {}

  @override
  Future<GitHostRepo> createRepo(String name) async {
    return GitHub.repoFromJson({});
  }

  @override
  Future<GitHostRepo> getRepo(String name) async {
    return GitHub.repoFromJson({});
  }

  @override
  Future<List<GitHostRepo>> listRepos() async {
    List<dynamic> list = jsonDecode(data);
    var repos = <GitHostRepo>[];
    list.forEach((dynamic d) {
      var map = Map<String, dynamic>.from(d);
      var repo = GitHub.repoFromJson(map);
      repos.add(repo);
    });

    return repos;
  }
}
