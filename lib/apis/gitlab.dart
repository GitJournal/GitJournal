import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

import 'package:url_launcher/url_launcher.dart';

import 'dart:math';

String _randomString(int length) {
  var rand = new Random();
  var codeUnits = new List.generate(length, (index) {
    return rand.nextInt(33) + 89;
  });

  return new String.fromCharCodes(codeUnits);
}

class Gitlab {
  static const _clientID =
      "faf33c3716faf05bfb701b1b31e36c83a23c3ec2d7161f4ff00fba2275524d09";

  var _platform = const MethodChannel('gitjournal.io/git');
  var _accessCode = "";
  var _stateOAuth = "";

  void init(Function callback) {
    Future _handleMessages(MethodCall call) async {
      if (call.method != "onURL") {
        print("GitLab Unknown Call: " + call.method);
        return;
      }

      print("GitLab: Called onUrl with " + call.arguments.toString());

      var url = call.arguments["URL"];
      var uri = Uri.parse(url);

      var state = uri.queryParameters['state'];
      if (state != _stateOAuth) {
        print("GitLab: OAuth State incorrect");
        callback();
      }

      _accessCode = uri.queryParameters['access_token'];
      if (_accessCode == null) {
        print("GitLab: Missing access code. Now what?");
        callback();
      }

      callback();
    }

    _platform.setMethodCallHandler(_handleMessages);
    print("GitLab: Installed Handler");
  }

  Future launchOAuthScreen() async {
    _stateOAuth = _randomString(10);

    var url =
        "https://gitlab.com/oauth/authorize?client_id=$_clientID&response_type=token&state=$_stateOAuth&redirect_uri=gitjournal://login.oauth2";
    return launch(url);
  }

  Future<List<GitLabRepo>> listRepos() async {
    if (_accessCode.isEmpty) {
      throw "GitHub Access Code Missing";
    }

    // FIXME: pagination!
    var url =
        "https://gitlab.com/api/v4/projects?simple=true&membership=true&order_by=last_activity_at&access_token=$_accessCode";

    var response = await http.get(url);
    if (response.statusCode != 200) {
      print("GitLab listRepos: Invalid response " +
          response.statusCode.toString() +
          ": " +
          response.body);
      return null;
    }

    List<dynamic> list = jsonDecode(response.body);
    List<GitLabRepo> repos = new List<GitLabRepo>();
    list.forEach((dynamic d) {
      var map = Map<String, dynamic>.from(d);
      var repo = GitLabRepo.fromJson(map);
      repos.add(repo);
    });

    // FIXME: Sort these based on some criteria
    return repos;
  }

// FIXME: Proper error when the repo exists!
  Future<GitLabRepo> createRepo(String name) async {
    if (_accessCode.isEmpty) {
      throw "GitLab Access Code Missing";
    }

    var url = "https://gitlab.com/api/v4/projects?access_token=$_accessCode";
    Map<String, dynamic> data = {
      'name': name,
      'visibility': 'private',
    };

    var headers = {
      HttpHeaders.contentTypeHeader: "application/json",
    };

    var response =
        await http.post(url, headers: headers, body: json.encode(data));
    if (response.statusCode != 201) {
      print("GitLab createRepo: Invalid response " +
          response.statusCode.toString() +
          ": " +
          response.body);
      return null;
    }

    print("GitLab createRepo: " + response.body);
    var map = json.decode(response.body);
    return GitLabRepo.fromJson(map);
  }

  Future addDeployKey(String sshPublicKey, String repo) async {
    if (_accessCode.isEmpty) {
      throw "GitLab Access Code Missing";
    }

    repo = repo.replaceAll('/', '%2F');
    var url =
        "https://gitlab.com/api/v4/projects/$repo/deploy_keys?access_token=$_accessCode";

    Map<String, dynamic> data = {
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
      print("GitLab addDeployKey: Invalid response " +
          response.statusCode.toString() +
          ": " +
          response.body);
      return null;
    }

    print("GitLab addDeployKey: " + response.body);
    return json.decode(response.body);
  }
}

class GitLabRepo {
  String fullName;
  String cloneUrl;

  GitLabRepo({this.fullName, this.cloneUrl});
  factory GitLabRepo.fromJson(Map<String, dynamic> parsedJson) {
    return new GitLabRepo(
      fullName: parsedJson['path_with_namespace'],
      cloneUrl: parsedJson['ssh_url_to_repo'],
    );
  }

  @override
  String toString() {
    return 'GitLabRepo{fulleName: $fullName, cloneUrl: $cloneUrl}';
  }
}
