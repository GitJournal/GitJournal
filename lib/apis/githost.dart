import 'dart:async';

abstract class GitHost {
  void init(Function oAuthCallback);
  Future launchOAuthScreen();

  Future<List<GitRepo>> listRepos();
  Future<GitRepo> createRepo(String name);
  Future addDeployKey(String sshPublicKey, String repo);
}

class GitRepo {
  String fullName;
  String cloneUrl;

  GitRepo({this.fullName, this.cloneUrl});

  @override
  String toString() {
    return 'GitRepo{fulleName: $fullName, cloneUrl: $cloneUrl}';
  }
}

class GitHostException implements Exception {
  static const OAuthFailed = const GitHostException("OAuthFailed");
  static const RepoExists = const GitHostException("RepoExists");

  final String cause;
  const GitHostException(this.cause);

  @override
  String toString() {
    return "GitHostException: " + cause;
  }
}
