/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:gitjournal/apis/githost.dart';

class GitHostExceptionCatcher implements GitHost {
  final GitHost _;

  GitHostExceptionCatcher(GitHost host) : _ = host;

  @override
  void init(OAuthCallback oAuthCallback) => _.init(oAuthCallback);
  @override
  Future<void> launchOAuthScreen() => _.launchOAuthScreen();

  @override
  Future<Result<UserInfo>> getUserInfo() => catchAll(_.getUserInfo);
  @override
  Future<Result<List<GitHostRepo>>> listRepos() => catchAll(_.listRepos);

  @override
  Future<Result<GitHostRepo>> createRepo(String name) =>
      catchAll(() => _.createRepo(name));

  @override
  Future<Result<GitHostRepo>> getRepo(String name) =>
      catchAll(() => _.getRepo(name));

  @override
  Future<Result<void>> addDeployKey(String sshPublicKey, String repoFullName) =>
      catchAll(() => _.addDeployKey(sshPublicKey, repoFullName));
}
