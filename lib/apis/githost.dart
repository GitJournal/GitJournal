import 'dart:async';

import 'package:flutter/foundation.dart';

typedef OAuthCallback = void Function(GitHostException);

abstract class GitHost {
  void init(OAuthCallback oAuthCallback);
  Future launchOAuthScreen();

  Future<UserInfo> getUserInfo();
  Future<List<GitHostRepo>> listRepos();
  Future<GitHostRepo> createRepo(String name);
  Future<GitHostRepo> getRepo(String name);
  Future addDeployKey(String sshPublicKey, String repo);
}

class UserInfo {
  String name;
  String email;
  String username;

  UserInfo({
    @required this.name,
    @required this.email,
    @required this.username,
  });
}

class GitHostRepo {
  String fullName;
  String cloneUrl;

  GitHostRepo({this.fullName, this.cloneUrl});

  @override
  String toString() {
    return 'GitRepo{fulleName: $fullName, cloneUrl: $cloneUrl}';
  }
}

class GitHostException implements Exception {
  static const OAuthFailed = GitHostException("OAuthFailed");
  static const MissingAccessCode = GitHostException("MissingAccessCode");
  static const RepoExists = GitHostException("RepoExists");
  static const CreateRepoFailed = GitHostException("CreateRepoFailed");
  static const DeployKeyFailed = GitHostException("DeployKeyFailed");
  static const GetRepoFailed = GitHostException("GetRepoFailed");

  final String cause;
  const GitHostException(this.cause);

  @override
  String toString() {
    return "GitHostException: " + cause;
  }
}
