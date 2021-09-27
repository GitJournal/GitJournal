/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:collection/collection.dart';
import 'package:dart_git/utils/result.dart';

export 'package:dart_git/utils/result.dart';

typedef OAuthCallback = void Function(GitHostException?);

abstract class GitHost {
  void init(OAuthCallback oAuthCallback);
  Future<void> launchOAuthScreen();

  Future<Result<UserInfo>> getUserInfo();
  Future<Result<List<GitHostRepo>>> listRepos();
  Future<Result<GitHostRepo>> createRepo(String name);
  Future<Result<GitHostRepo>> getRepo(String name);
  Future<Result<void>> addDeployKey(String sshPublicKey, String repoFullName);
}

class UserInfo {
  final String name;
  final String email;
  final String username;

  UserInfo({
    required this.name,
    required this.email,
    required this.username,
  });

  @override
  String toString() {
    return kDebugMode
        ? 'UserInfo{name: "$name", email: "$email", username: "$username"}'
        : 'UserInfo{name: ${name.isNotEmpty}, email: ${email.isNotEmpty}, username: ${username.isNotEmpty}}';
  }
}

class GitHostRepo {
  final String name;
  final String username;
  final String fullName;
  final String description;

  final String cloneUrl;
  final DateTime? updatedAt;

  final bool? private;
  final int? stars;
  final int? forks;
  final String? language;
  final int? issues;
  final String? license;

  final List<String> tags;

  GitHostRepo({
    required this.name,
    required this.username,
    required this.fullName,
    required this.description,
    required this.cloneUrl,
    required this.updatedAt,
    required this.private,
    required this.stars,
    required this.forks,
    required this.language,
    required this.issues,
    required this.tags,
    required this.license,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'username': username,
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GitHostRepo &&
          runtimeType == other.runtimeType &&
          _mapEquals(toJson(), other.toJson());
  @override
  int get hashCode => toJson().hashCode;
}

final _mapEquals = (const MapEquality()).equals;

class GitHostException implements Exception {
  static const OAuthFailed = GitHostException("OAuthFailed");
  static const MissingAccessCode = GitHostException("MissingAccessCode");
  static const RepoExists = GitHostException("RepoExists");
  static const CreateRepoFailed = GitHostException("CreateRepoFailed");
  static const DeployKeyFailed = GitHostException("DeployKeyFailed");
  static const GetRepoFailed = GitHostException("GetRepoFailed");
  static const HttpResponseFail = GitHostException("HttpResponseFail");
  static const JsonDecodingFail = GitHostException("JsonDecodingFail");

  final String cause;
  const GitHostException(this.cause);

  @override
  String toString() {
    return "GitHostException: " + cause;
  }
}

String toCurlCommand(Uri url, Map<String, String> headers) {
  var headersStr = "";
  headers.forEach((key, value) {
    headersStr += ' -H "$key: $value" ';
  });

  return "curl -X GET '$url' $headersStr";
}
