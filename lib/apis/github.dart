import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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
        Fimber.d("GitHub Unknown Call: " + call.method);
        return;
      }

      Fimber.d("GitHub: Called onUrl with " + call.arguments.toString());

      String url = call.arguments["URL"];
      var uri = Uri.parse(url);
      var authCode = uri.queryParameters['code'];
      if (authCode == null) {
        Fimber.d("GitHub: Missing auth code. Now what?");
        callback(GitHostException.OAuthFailed);
      }

      _accessCode = await _getAccessCode(authCode);
      if (_accessCode == null || _accessCode.isEmpty) {
        Fimber.d("GitHub: AccessCode is invalid: " + _accessCode);
        callback(GitHostException.OAuthFailed);
      }

      callback(null);
    }

    _platform.setMethodCallHandler(_handleMessages);
    Fimber.d("GitHub: Installed Handler");
  }

  Future<String> _getAccessCode(String authCode) async {
    var url =
        "https://github.com/login/oauth/access_token?client_id=$_clientID&client_secret=$_clientSecret&code=$authCode";

    var response = await http.post(url);
    if (response.statusCode != 200) {
      Fimber.d("Github getAccessCode: Invalid response " +
          response.statusCode.toString() +
          ": " +
          response.body);
      throw GitHostException.OAuthFailed;
    }
    Fimber.d("GithubResponse: " + response.body);

    var map = Uri.splitQueryString(response.body);
    return map["access_token"];
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

    var url =
        "https://api.github.com/user/repos?page=1&per_page=100&access_token=$_accessCode";

    var response = await http.get(url);
    if (response.statusCode != 200) {
      Fimber.d("Github listRepos: Invalid response " +
          response.statusCode.toString() +
          ": " +
          response.body);
      return null;
    }

    List<dynamic> list = jsonDecode(response.body);
    var repos = <GitHostRepo>[];
    list.forEach((dynamic d) {
      var map = Map<String, dynamic>.from(d);
      var repo = _repoFromJson(map);
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

    var url = "https://api.github.com/user/repos?access_token=$_accessCode";
    var data = <String, dynamic>{
      'name': name,
      'private': true,
    };

    var headers = {
      HttpHeaders.contentTypeHeader: "application/json",
    };

    var response =
        await http.post(url, headers: headers, body: json.encode(data));
    if (response.statusCode != 201) {
      Fimber.d("Github createRepo: Invalid response " +
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

    Fimber.d("GitHub createRepo: " + response.body);
    Map<String, dynamic> map = json.decode(response.body);
    return _repoFromJson(map);
  }

  @override
  Future<GitHostRepo> getRepo(String name) async {
    if (_accessCode.isEmpty) {
      throw GitHostException.MissingAccessCode;
    }

    var userInfo = await getUserInfo();
    var owner = userInfo.username;
    var url =
        "https://api.github.com/repos/$owner/$name?access_token=$_accessCode";

    var response = await http.get(url);
    if (response.statusCode != 200) {
      Fimber.d("Github getRepo: Invalid response " +
          response.statusCode.toString() +
          ": " +
          response.body);

      throw GitHostException.GetRepoFailed;
    }

    Fimber.d("GitHub getRepo: " + response.body);
    Map<String, dynamic> map = json.decode(response.body);
    return _repoFromJson(map);
  }

  @override
  Future addDeployKey(String sshPublicKey, String repo) async {
    if (_accessCode.isEmpty) {
      throw GitHostException.MissingAccessCode;
    }

    var url =
        "https://api.github.com/repos/$repo/keys?access_token=$_accessCode";

    var data = <String, dynamic>{
      'title': "GitJournal",
      'key': sshPublicKey,
      'read_only': false,
    };

    var headers = {
      HttpHeaders.contentTypeHeader: "application/json",
    };

    var response =
        await http.post(url, headers: headers, body: json.encode(data));
    if (response.statusCode != 201) {
      Fimber.d("Github addDeployKey: Invalid response " +
          response.statusCode.toString() +
          ": " +
          response.body);
      throw GitHostException.DeployKeyFailed;
    }

    Fimber.d("GitHub addDeployKey: " + response.body);
    return json.decode(response.body);
  }

  GitHostRepo _repoFromJson(Map<String, dynamic> parsedJson) {
    return GitHostRepo(
      fullName: parsedJson['full_name'],
      cloneUrl: parsedJson['ssh_url'],
    );
  }

  @override
  Future<UserInfo> getUserInfo() async {
    if (_accessCode.isEmpty) {
      throw GitHostException.MissingAccessCode;
    }

    var url = "https://api.github.com/user?access_token=$_accessCode";

    var response = await http.get(url);
    if (response.statusCode != 200) {
      Fimber.d("Github getUserInfo: Invalid response " +
          response.statusCode.toString() +
          ": " +
          response.body);
      return null;
    }

    Map<String, dynamic> map = jsonDecode(response.body);
    if (map == null || map.isEmpty) {
      Fimber.d("Github getUserInfo: jsonDecode Failed " +
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
}
