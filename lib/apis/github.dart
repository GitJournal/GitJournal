import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gitjournal/utils.dart';
import 'package:gitjournal/utils/logger.dart';
import 'githost.dart';

class GitHub implements GitHost {
  static const _clientID = "aa3072cbfb02b1db14ed";
  static const _clientSecret = "010d303ea99f82330f2b228977cef9ddbf7af2cd";

  var _platform = const MethodChannel('gitjournal.io/git');
  var _accessCode = "";

  @override
  void init(OAuthCallback callback) {
    Future _handleMessages(MethodCall call) async {
      if (call.method != "onURL") {
        Log.d("GitHub Unknown Call: " + call.method);
        return;
      }

      closeWebView();
      Log.d("GitHub: Called onUrl with " + call.arguments.toString());

      String url = call.arguments["URL"];
      var uri = Uri.parse(url);
      var authCode = uri.queryParameters['code'] ?? "";
      if (authCode.isEmpty) {
        Log.d("GitHub: Missing auth code. Now what?");
        callback(GitHostException.OAuthFailed);
      }

      _accessCode = await _getAccessCode(authCode);
      if (_accessCode.isEmpty) {
        Log.d("GitHub: AccessCode is invalid: " + _accessCode);
        callback(GitHostException.OAuthFailed);
      }

      callback(null);
    }

    _platform.setMethodCallHandler(_handleMessages);
    Log.d("GitHub: Installed Handler");
  }

  Future<String> _getAccessCode(String authCode) async {
    var url =
        "https://github.com/login/oauth/access_token?client_id=$_clientID&client_secret=$_clientSecret&code=$authCode";

    var response = await http.post(url);
    if (response.statusCode != 200) {
      Log.d("Github getAccessCode: Invalid response " +
          response.statusCode.toString() +
          ": " +
          response.body);
      throw GitHostException.OAuthFailed;
    }
    Log.d("GithubResponse: " + response.body);

    var map = Uri.splitQueryString(response.body);
    return map["access_token"] ?? "";
  }

  @override
  Future launchOAuthScreen() async {
    // FIXME: Add some 'state' over here!

    var url = "https://github.com/login/oauth/authorize?client_id=" +
        _clientID +
        "&scope=repo";
    return launch(url);
  }

  @override
  Future<List<GitHostRepo>> listRepos() async {
    if (_accessCode.isEmpty) {
      throw GitHostException.MissingAccessCode;
    }

    var url = "https://api.github.com/user/repos?page=1&per_page=100";
    var headers = {
      HttpHeaders.authorizationHeader: _buildAuthHeader(),
    };

    if (foundation.kDebugMode) {
      print(toCurlCommand(url, headers));
    }

    var response = await http.get(url, headers: headers);
    if (response.statusCode != 200) {
      Log.d("Github listRepos: Invalid response " +
          response.statusCode.toString() +
          ": " +
          response.body);
      return null;
    }

    List<dynamic> list = jsonDecode(response.body);
    var repos = <GitHostRepo>[];
    list.forEach((dynamic d) {
      var map = Map<String, dynamic>.from(d);
      var repo = repoFromJson(map);
      repos.add(repo);
    });

    // FIXME: Sort these based on some criteria
    return repos;
  }

  @override
  Future<GitHostRepo> createRepo(String name) async {
    if (_accessCode.isEmpty) {
      throw GitHostException.MissingAccessCode;
    }

    var url = "https://api.github.com/user/repos";
    var data = <String, dynamic>{
      'name': name,
      'private': true,
    };

    var headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: _buildAuthHeader(),
    };

    var response =
        await http.post(url, headers: headers, body: json.encode(data));
    if (response.statusCode != 201) {
      Log.d("Github createRepo: Invalid response " +
          response.statusCode.toString() +
          ": " +
          response.body);

      if (response.statusCode == 422) {
        if (response.body.contains("name already exists")) {
          throw GitHostException.RepoExists;
        }
      }

      throw GitHostException.CreateRepoFailed;
    }

    Log.d("GitHub createRepo: " + response.body);
    Map<String, dynamic> map = json.decode(response.body);
    return repoFromJson(map);
  }

  @override
  Future<GitHostRepo> getRepo(String name) async {
    if (_accessCode.isEmpty) {
      throw GitHostException.MissingAccessCode;
    }

    var userInfo = await getUserInfo();
    var owner = userInfo.username;
    var url = "https://api.github.com/repos/$owner/$name";

    var headers = {
      HttpHeaders.authorizationHeader: _buildAuthHeader(),
    };

    var response = await http.get(url, headers: headers);
    if (response.statusCode != 200) {
      Log.d("Github getRepo: Invalid response " +
          response.statusCode.toString() +
          ": " +
          response.body);

      throw GitHostException.GetRepoFailed;
    }

    Log.d("GitHub getRepo: " + response.body);
    Map<String, dynamic> map = json.decode(response.body);
    return repoFromJson(map);
  }

  @override
  Future addDeployKey(String sshPublicKey, String repo) async {
    if (_accessCode.isEmpty) {
      throw GitHostException.MissingAccessCode;
    }

    var url = "https://api.github.com/repos/$repo/keys";

    var data = <String, dynamic>{
      'title': "GitJournal",
      'key': sshPublicKey,
      'read_only': false,
    };

    var headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: _buildAuthHeader(),
    };

    var response =
        await http.post(url, headers: headers, body: json.encode(data));
    if (response.statusCode != 201) {
      Log.d("Github addDeployKey: Invalid response " +
          response.statusCode.toString() +
          ": " +
          response.body);
      throw GitHostException.DeployKeyFailed;
    }

    Log.d("GitHub addDeployKey: " + response.body);
    return json.decode(response.body);
  }

  @visibleForTesting
  GitHostRepo repoFromJson(Map<String, dynamic> parsedJson) {
    DateTime updatedAt;
    try {
      updatedAt = DateTime.parse(parsedJson['updated_at'].toString());
    } catch (e) {
      Log.e(e);
    }
    var licenseMap = parsedJson['license'];

    /*
    print("");
    parsedJson.forEach((key, value) => print(" $key: $value"));
    print("");
    */

    return GitHostRepo(
      fullName: parsedJson['full_name'],
      cloneUrl: parsedJson['ssh_url'],
      updatedAt: updatedAt,
      description: parsedJson['description'],
      stars: parsedJson['stargazers_count'],
      forks: parsedJson['forks_count'],
      issues: parsedJson['open_issues_count'],
      language: parsedJson['language'],
      private: parsedJson['private'],
      tags: parsedJson['topics'],
      license: licenseMap != null ? licenseMap['spdx_id'] : null,
    );
  }

  @override
  Future<UserInfo> getUserInfo() async {
    if (_accessCode.isEmpty) {
      throw GitHostException.MissingAccessCode;
    }

    var url = "https://api.github.com/user";

    var headers = {
      HttpHeaders.authorizationHeader: _buildAuthHeader(),
    };

    var response = await http.get(url, headers: headers);
    if (response.statusCode != 200) {
      Log.d("Github getUserInfo: Invalid response " +
          response.statusCode.toString() +
          ": " +
          response.body);
      return null;
    }

    Map<String, dynamic> map = jsonDecode(response.body);
    if (map == null || map.isEmpty) {
      Log.d("Github getUserInfo: jsonDecode Failed " +
          response.statusCode.toString() +
          ": " +
          response.body);
      return null;
    }

    return UserInfo(
      name: map['name'],
      email: map['email'],
      username: map['login'],
    );
  }

  String _buildAuthHeader() {
    return 'token $_accessCode';
  }
}
