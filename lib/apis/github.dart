import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

import 'package:url_launcher/url_launcher.dart';

const _clientID = "aa3072cbfb02b1db14ed";
const _clientSecret = "010d303ea99f82330f2b228977cef9ddbf7af2cd";
const _platform = const MethodChannel('gitjournal.io/git');

Future<String> getAccessCode(String authCode) async {
  var url =
      "https://github.com/login/oauth/access_token?client_id=${_clientID}&client_secret=${_clientSecret}&code=${authCode}";

  var response = await http.post(url);
  if (response.statusCode != 200) {
    print("Github getAccessCode: Invalid response " +
        response.statusCode.toString() +
        ": " +
        response.body);
    return null;
  }
  print("GithubResponse: " + response.body);

  var map = Uri.splitQueryString(response.body);
  return map["access_token"];
}

void initGitHub(Function callback) {
  Future _handleMessages(MethodCall call) async {
    if (call.method != "onURL") {
      print("GitHub Unknown Call: " + call.method);
      return;
    }

    print("GitHub: Called onUrl with " + call.arguments.toString());

    var url = call.arguments["URL"];
    var uri = Uri.parse(url);
    var authCode = uri.queryParameters['code'];
    if (authCode == null) {
      print("GitHub: Missing auth code. Now what?");
      callback();
    }

    var acesssCode = await getAccessCode(authCode);
    callback(acesssCode);
  }

  _platform.setMethodCallHandler(_handleMessages);
  print("GitHub: Installed Handler");
}

Future launchOAuthScreen() async {
  // FIXME: Add some 'state' over here!

  var url = "https://github.com/login/oauth/authorize?client_id=" +
      _clientID +
      "&scope=repo";
  return launch(url);
}

class Repo {
  String fullName;

  Repo({this.fullName});
  factory Repo.fromJson(Map<String, dynamic> parsedJson) {
    return new Repo(fullName: parsedJson['full_name']);
  }

  @override
  String toString() {
    return 'Repo{fulleName: $fullName}';
  }
}

Future<List<Repo>> listRepos(String accessCode) async {
  var url =
      "https://api.github.com/user/repos?page=1&per_page=100&access_token=${accessCode}";

  var response = await http.get(url);
  if (response.statusCode != 200) {
    print("Github listRepos: Invalid response " +
        response.statusCode.toString() +
        ": " +
        response.body);
    return null;
  }

  List<dynamic> list = jsonDecode(response.body);
  List<Repo> repos = new List<Repo>();
  list.forEach((dynamic d) {
    var map = Map<String, dynamic>.from(d);
    var repo = Repo.fromJson(map);
    repos.add(repo);
  });

  // FIXME: Sort these based on some criteria
  return repos;
}

Future createRepo(String accessCode, String name) async {
  var url = "https://api.github.com/user/repos?access_token=${accessCode}";
  Map<String, dynamic> data = {
    'name': name,
    'private': true,
  };

  var headers = {
    HttpHeaders.contentTypeHeader: "application/json",
  };

  var response =
      await http.post(url, headers: headers, body: json.encode(data));
  if (response.statusCode != 201) {
    print("Github createRepo: Invalid response " +
        response.statusCode.toString() +
        ": " +
        response.body);
    return null;
  }

  print("GitHub createRepo: " + response.body);
  return json.decode(response.body);
}

Future addDeployKey(String accessCode, String sshPublicKey, String repo) async {
  var url =
      "https://api.github.com/repos/$repo/keys?access_token=${accessCode}";

  Map<String, dynamic> data = {
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
    print("Github addDeployKey: Invalid response " +
        response.statusCode.toString() +
        ": " +
        response.body);
    return null;
  }

  print("GitHub addDeployKey: " + response.body);
  return json.decode(response.body);
}
