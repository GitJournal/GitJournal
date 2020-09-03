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
  Future addDeployKey(String sshPublicKey, String repoFullName);
}

class UserInfo {
  final String name;
  final String email;
  final String username;

  UserInfo({
    @required this.name,
    @required this.email,
    @required this.username,
  });
}

class GitHostRepo {
  final String fullName;
  final String description;

  final String cloneUrl;
  final DateTime updatedAt;

  final bool private;
  final int stars;
  final int forks;
  final String language;
  final int issues;
  final String license;

  final List<String> tags;

  GitHostRepo({
    @required this.fullName,
    @required this.description,
    @required this.cloneUrl,
    @required this.updatedAt,
    @required this.private,
    @required this.stars,
    @required this.forks,
    @required this.language,
    @required this.issues,
    @required this.tags,
    @required this.license,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'description': description,
        'cloneUrl': cloneUrl,
        'updatedAt': updatedAt,
        'private': private,
        'stars': stars,
        'forks': forks,
        'language': language,
        'issues': issues,
        'tags': tags,
        'license': license,
      };

  @override
  String toString() => toJson().toString();
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
