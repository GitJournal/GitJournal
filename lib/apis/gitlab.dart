/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:universal_io/io.dart' show HttpHeaders;
import 'package:url_launcher/url_launcher.dart';

import 'package:gitjournal/logger/logger.dart';
import 'githost.dart';

// FIXME: Handle for edge cases of json.decode

class GitLab implements GitHost {
  static const _clientID =
      "faf33c3716faf05bfb701b1b31e36c83a23c3ec2d7161f4ff00fba2275524d09";

  final _platform = const MethodChannel('gitjournal.io/git');
  String? _accessCode = "";
  var _stateOAuth = "";

  @override
  void init(OAuthCallback callback) {
    Future _handleMessages(MethodCall call) async {
      if (call.method != "onURL") {
        Log.d("GitLab Unknown Call: " + call.method);
        return;
      }

      closeWebView();
      Log.d("GitLab: Called onUrl with " + call.arguments.toString());

      String url = call.arguments["URL"];
      var queryParamters = url.substring(url.indexOf('#') + 1);
      var map = Uri.splitQueryString(queryParamters);

      var state = map['state'];
      if (state != _stateOAuth) {
        Log.d("GitLab: OAuth State incorrect");
        Log.d("Required State: " + _stateOAuth);
        Log.d("Actual State: " + state!);
        callback(GitHostException.OAuthFailed);
        return;
      }

      _accessCode = map['access_token'];
      if (_accessCode == null) {
        callback(GitHostException.OAuthFailed);
        return;
      }

      callback(null);
    }

    _platform.setMethodCallHandler(_handleMessages);
    Log.d("GitLab: Installed Handler");
  }

  @override
  Future<void> launchOAuthScreen() async {
    _stateOAuth = _randomString(10);

    var url =
        "https://gitlab.com/oauth/authorize?client_id=$_clientID&response_type=token&state=$_stateOAuth&redirect_uri=gitjournal://login.oauth2";
    var _ = await launch(url);
  }

  @override
  Future<Result<List<GitHostRepo>>> listRepos() async {
    if (_accessCode!.isEmpty) {
      var ex = GitHostException.MissingAccessCode;
      return Result.fail(ex);
    }

    // FIXME: pagination!
    var url = Uri.parse(
        "https://gitlab.com/api/v4/projects?simple=true&membership=true&order_by=last_activity_at&access_token=$_accessCode");

    if (foundation.kDebugMode) {
      Log.d(toCurlCommand(url, {}));
    }

    var response = await http.get(url);
    if (response.statusCode != 200) {
      Log.e("GitLab listRepos: Invalid response " +
          response.statusCode.toString() +
          ": " +
          response.body);
      var ex = GitHostException.HttpResponseFail;
      return Result.fail(ex);
    }

    List<dynamic> list = jsonDecode(response.body);
    var repos = <GitHostRepo>[];
    for (var d in list) {
      var map = Map<String, dynamic>.from(d);
      var repo = repoFromJson(map);
      repos.add(repo);
    }

    // FIXME: Sort these based on some criteria
    return Result(repos);
  }

  @override
  Future<Result<GitHostRepo>> createRepo(String name) async {
    if (_accessCode!.isEmpty) {
      var ex = GitHostException.MissingAccessCode;
      return Result.fail(ex);
    }

    var url = Uri.parse(
        "https://gitlab.com/api/v4/projects?access_token=$_accessCode");
    var data = <String, dynamic>{
      'name': name,
      'visibility': 'private',
    };

    var headers = {
      HttpHeaders.contentTypeHeader: "application/json",
    };

    var response =
        await http.post(url, headers: headers, body: json.encode(data));
    if (response.statusCode != 201) {
      Log.e("GitLab createRepo: Invalid response " +
          response.statusCode.toString() +
          ": " +
          response.body);

      if (response.statusCode == 400) {
        if (response.body.contains("has already been taken")) {
          var ex = GitHostException.RepoExists;
          return Result.fail(ex);
        }
      }

      var ex = GitHostException.CreateRepoFailed;
      return Result.fail(ex);
    }

    Log.d("GitLab createRepo: " + response.body);
    Map<String, dynamic> map = json.decode(response.body);
    return Result(repoFromJson(map));
  }

  @override
  Future<Result<GitHostRepo>> getRepo(String name) async {
    if (_accessCode!.isEmpty) {
      var ex = GitHostException.MissingAccessCode;
      return Result.fail(ex);
    }

    var userInfoR = await getUserInfo();
    if (userInfoR.isFailure) {
      return fail(userInfoR);
    }
    var userInfo = userInfoR.getOrThrow();
    var repo = userInfo.username + '%2F' + name;
    var url = Uri.parse(
        "https://gitlab.com/api/v4/projects/$repo?access_token=$_accessCode");

    var response = await http.get(url);
    if (response.statusCode != 200) {
      Log.e("GitLab getRepo: Invalid response " +
          response.statusCode.toString() +
          ": " +
          response.body);

      var ex = GitHostException.GetRepoFailed;
      return Result.fail(ex);
    }

    Log.d("GitLab getRepo: " + response.body);
    Map<String, dynamic> map = json.decode(response.body);
    return Result(repoFromJson(map));
  }

  @override
  Future<Result<void>> addDeployKey(String sshPublicKey, String repo) async {
    if (_accessCode!.isEmpty) {
      var ex = GitHostException.MissingAccessCode;
      return Result.fail(ex);
    }

    repo = repo.replaceAll('/', '%2F');
    var url = Uri.parse(
        "https://gitlab.com/api/v4/projects/$repo/deploy_keys?access_token=$_accessCode");

    var data = {
      'title': "GitJournal",
      'key': sshPublicKey,
      'can_push': true,
    };

    var headers = {
      HttpHeaders.contentTypeHeader: "application/json",
    };

    var response =
        await http.post(url, headers: headers, body: json.encode(data));
    if (response.statusCode != 201) {
      Log.e("GitLab addDeployKey: Invalid response " +
          response.statusCode.toString() +
          ": " +
          response.body);
      var ex = GitHostException.DeployKeyFailed;
      return Result.fail(ex);
    }

    Log.d("GitLab addDeployKey: " + response.body);
    return Result(null);
  }

  static GitHostRepo repoFromJson(Map<String, dynamic> parsedJson) {
    DateTime? updatedAt;
    try {
      updatedAt = DateTime.parse(parsedJson['last_activity_at'].toString());
    } catch (e, st) {
      Log.e("gitlab repoFromJson", ex: e, stacktrace: st);
    }
    var licenseMap = parsedJson['license'];

    List<String> tags = [];
    var tagList = parsedJson['tag_list'];
    if (tagList is List) {
      tags = tagList.map((e) => e.toString()).toList();
    }

    var fullName = parsedJson['path_with_namespace'].toString();
    var namespace = parsedJson['namespace'];
    var username = "";
    if (namespace != null) {
      username = (namespace as Map)["path"];
    } else {
      username = fullName.split('/').first;
    }

    return GitHostRepo(
      name: parsedJson["name"],
      username: username,
      fullName: fullName,
      cloneUrl: parsedJson['ssh_url_to_repo'],
      updatedAt: updatedAt,
      description: parsedJson['description'] ?? "",
      stars: parsedJson['star_count'],
      forks: parsedJson['forks_count'],
      issues: parsedJson['open_issues_count'],
      language: parsedJson['language'],
      private: parsedJson['visibility'] == 'private',
      tags: tags,
      license: licenseMap != null ? licenseMap['nickname'] : null,
    );
  }

  @override
  Future<Result<UserInfo>> getUserInfo() async {
    if (_accessCode!.isEmpty) {
      var ex = GitHostException.MissingAccessCode;
      return Result.fail(ex);
    }

    var url =
        Uri.parse("https://gitlab.com/api/v4/user?access_token=$_accessCode");

    var response = await http.get(url);
    if (response.statusCode != 200) {
      Log.e("GitLab getUserInfo: Invalid response " +
          response.statusCode.toString() +
          ": " +
          response.body);

      var ex = GitHostException.HttpResponseFail;
      return Result.fail(ex);
    }

    Map<String, dynamic>? map = jsonDecode(response.body);
    if (map == null || map.isEmpty) {
      Log.e("GitLab getUserInfo: jsonDecode Failed " +
          response.statusCode.toString() +
          ": " +
          response.body);

      var ex = GitHostException.JsonDecodingFail;
      return Result.fail(ex);
    }

    return Result(UserInfo(
      name: map['name'],
      email: map['email'],
      username: map['username'],
    ));
  }
}

String _randomString(int length) {
  var rand = Random();
  var codeUnits = List.generate(length, (index) {
    return rand.nextInt(33) + 89;
  });

  return String.fromCharCodes(codeUnits);
}
