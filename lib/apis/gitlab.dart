import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:flutter_web_auth/flutter_web_auth.dart';

import 'package:gitjournal/utils/logger.dart';
import 'githost.dart';

class GitLab implements GitHost {
  static const _clientID =
      "faf33c3716faf05bfb701b1b31e36c83a23c3ec2d7161f4ff00fba2275524d09";

  var _accessCode = "";
  var _stateOAuth = "";

  @override
  Future<void> init() async {
    _stateOAuth = _randomString(10);

    var launchUrl =
        "https://gitlab.com/oauth/authorize?client_id=$_clientID&response_type=token&state=$_stateOAuth&redirect_uri=gitjournal://login.oauth2";

    var url = await FlutterWebAuth.authenticate(
        url: launchUrl, callbackUrlScheme: "gitjournal");

    var receievedState = _fetchQueryParam(url, "state");
    if (receievedState != _stateOAuth) {
      Log.d("GitLab: OAuth State incorrect");
      Log.d("Required State: $_stateOAuth");
      Log.d("Actual State: $receievedState");
      throw GitHostException.OAuthFailed;
    }

    _accessCode = _fetchQueryParam(url, "access_token");
    if (_accessCode == null) {
      throw GitHostException.OAuthFailed;
    }
  }

  // Example: gitjournal://login.oauth2#access_token=49ce9d1s11145acc7bddf0b6b2a5fbe2a15496e4975808731e054eceeb49468f&token_type=Bearer&state=qxpYY%5CckY%5D
  String _fetchQueryParam(String url, String param) {
    var map = Uri.parse(url).queryParameters;
    var value = map[param];
    if (value != null && value.isNotEmpty) {
      return value;
    }

    var paramIndex = url.indexOf("$param=");
    if (paramIndex != -1) {
      var stateStr = url.substring(paramIndex + "$param=".length).split('&')[0];
      return Uri.decodeQueryComponent(stateStr);
    }

    return "";
  }

  @override
  Future<List<GitHostRepo>> listRepos() async {
    if (_accessCode.isEmpty) {
      throw GitHostException.MissingAccessCode;
    }

    // FIXME: pagination!
    var url =
        "https://gitlab.com/api/v4/projects?simple=true&membership=true&order_by=last_activity_at&access_token=$_accessCode";

    var response = await http.get(url);
    if (response.statusCode != 200) {
      Log.d("GitLab listRepos: Invalid response " +
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

    var url = "https://gitlab.com/api/v4/projects?access_token=$_accessCode";
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
      Log.d("GitLab createRepo: Invalid response " +
          response.statusCode.toString() +
          ": " +
          response.body);

      if (response.statusCode == 400) {
        if (response.body.contains("has already been taken")) {
          throw GitHostException.RepoExists;
        }
      }

      throw GitHostException.CreateRepoFailed;
    }

    Log.d("GitLab createRepo: " + response.body);
    Map<String, dynamic> map = json.decode(response.body);
    return _repoFromJson(map);
  }

  @override
  Future<GitHostRepo> getRepo(String name) async {
    if (_accessCode.isEmpty) {
      throw GitHostException.MissingAccessCode;
    }

    var userInfo = await getUserInfo();
    var repo = userInfo.username + '%2F' + name;
    var url =
        "https://gitlab.com/api/v4/projects/$repo?access_token=$_accessCode";

    var response = await http.get(url);
    if (response.statusCode != 200) {
      Log.d("GitLab getRepo: Invalid response " +
          response.statusCode.toString() +
          ": " +
          response.body);

      throw GitHostException.GetRepoFailed;
    }

    Log.d("GitLab getRepo: " + response.body);
    Map<String, dynamic> map = json.decode(response.body);
    return _repoFromJson(map);
  }

  @override
  Future addDeployKey(String sshPublicKey, String repo) async {
    if (_accessCode.isEmpty) {
      throw GitHostException.MissingAccessCode;
    }

    repo = repo.replaceAll('/', '%2F');
    var url =
        "https://gitlab.com/api/v4/projects/$repo/deploy_keys?access_token=$_accessCode";

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
      Log.d("GitLab addDeployKey: Invalid response " +
          response.statusCode.toString() +
          ": " +
          response.body);
      throw GitHostException.DeployKeyFailed;
    }

    Log.d("GitLab addDeployKey: " + response.body);
    return json.decode(response.body);
  }

  GitHostRepo _repoFromJson(Map<String, dynamic> parsedJson) {
    DateTime updatedAt;
    try {
      updatedAt = DateTime.parse(parsedJson['last_activity_at'].toString());
    } catch (e) {
      Log.e(e);
    }

    return GitHostRepo(
      fullName: parsedJson['path_with_namespace'],
      cloneUrl: parsedJson['ssh_url_to_repo'],
      updatedAt: updatedAt,
    );
  }

  @override
  Future<UserInfo> getUserInfo() async {
    if (_accessCode.isEmpty) {
      throw GitHostException.MissingAccessCode;
    }

    var url = "https://gitlab.com/api/v4/user?access_token=$_accessCode";

    var response = await http.get(url);
    if (response.statusCode != 200) {
      Log.d("GitLab getUserInfo: Invalid response " +
          response.statusCode.toString() +
          ": " +
          response.body);
      return null;
    }

    Map<String, dynamic> map = jsonDecode(response.body);
    if (map == null || map.isEmpty) {
      Log.d("GitLab getUserInfo: jsonDecode Failed " +
          response.statusCode.toString() +
          ": " +
          response.body);
      return null;
    }

    return UserInfo(
      name: map['name'],
      email: map['email'],
      username: map['username'],
    );
  }
}

String _randomString(int length) {
  var rand = Random();
  var codeUnits = List.generate(length, (index) {
    return rand.nextInt(33) + 89;
  });

  return String.fromCharCodes(codeUnits);
}
