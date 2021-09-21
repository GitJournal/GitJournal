/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:gitjournal/apis/api_fakes.dart';
import 'package:gitjournal/apis/githost_factory.dart';
import 'package:gitjournal/setup/autoconfigure.dart';
import 'package:gitjournal/setup/clone_url.dart';
import 'package:gitjournal/setup/error.dart';
import 'package:gitjournal/setup/fakes/clone_fake.dart';
import 'package:gitjournal/setup/loading.dart';
import 'package:gitjournal/setup/repo_selector.dart';
import 'package:gitjournal/setup/screens.dart';
import 'package:gitjournal/setup/sshkey.dart';

Widget autoConfigureChoice() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: GitHostAutoConfigureChoicePage(
      onDone: (_) {},
    ),
  );
}

Widget gitHostChoice() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: GitHostChoicePage(
      onCustomGitHost: () {},
      onKnownGitHost: (_) {},
    ),
  );
}

Widget autoConfigure() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: GitHostSetupAutoConfigurePage(
      gitHostType: GitHostType.GitHub,
      onDone: (host, userInfo) {},
    ),
  );
}

Widget cloneUrl() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: GitCloneUrlPage(
      initialValue: "foo?",
      doneFunction: (val) {},
    ),
  );
}

// FIXME: Create widgets for all the errors!
Widget loadingError() {
  return const Padding(
    padding: EdgeInsets.all(16.0),
    child: GitHostSetupErrorPage(
      "This is an error message",
    ),
  );
}

// FIXME: Create widgets for all the loading screen messages!
Widget loading() {
  return const Padding(
    padding: EdgeInsets.all(16.0),
    child: GitHostSetupLoadingPage(
      "Loading Message",
    ),
  );
}

var _publicKey =
    "ecdsa-sha2-nistp384 AAAAE2VjZHNhLXNoYTItbmlzdHAzODQAAAAIbmlzdHAzODQAAABhBJ9OSG+YIxqsZiXWisqJIqRStX5wjy9oMrT9gnB85jgR03RjMBWpxXAtrlreo7ljDqhs9g3zdXq/oxcPgzyS+mm33A4WTGGY0u4RbxY14q8V1p/CVu5sd39UYpwYsj0HLw== vishesh@Visheshs-MacBook-Pro.local";

Widget sshKeyKnownProviderPage() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: GitHostSetupSshKeyKnownProviderPage(
      openDeployKeyPage: () {},
      copyKeyFunction: (_) {},
      publicKey: _publicKey,
      regenerateFunction: () {},
      doneFunction: () {},
    ),
  );
}

Widget sshKeyUnknownProviderPage() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: GitHostSetupSshKeyUnknownProviderPage(
      publicKey: _publicKey,
      regenerateFunction: () {},
      doneFunction: () {},
      copyKeyFunction: (_) {},
    ),
  );
}

Widget keyChoicePage() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: GitHostSetupKeyChoicePage(
      onGenerateKeys: () {},
      onUserProvidedKeys: () {},
    ),
  );
}

Widget keyUserProvidedKeysPage() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: GitHostUserProvidedKeysPage(
      doneFunction: (_, __, ___) {},
    ),
  );
}

Widget repoSelector() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: GitHostSetupRepoSelector(
      gitHost: GitHubFake(_gitHubData),
      userInfo: UserInfo(
        name: 'vhanda',
        email: 'me@vhanda.in',
        username: 'vhanda',
      ),
      onDone: (_) {},
    ),
  );
}

Widget cloning() {
  return const Padding(
    padding: EdgeInsets.all(16.0),
    child: FakeTransferProgress(),
  );
}

var _gitHubData = '''
[
  {
    "id": 229985363,
    "node_id": "MDEwOlJlcG9zaXRvcnkyMjk5ODUzNjM=",
    "name": "dart_git",
    "full_name": "GitJournal/dart_git",
    "private": false,
    "owner": {
      "login": "GitJournal",
      "id": 46486395,
      "node_id": "MDEyOk9yZ2FuaXphdGlvbjQ2NDg2Mzk1",
      "avatar_url": "https://avatars0.githubusercontent.com/u/46486395?v=4",
      "gravatar_id": "",
      "url": "https://api.github.com/users/GitJournal",
      "html_url": "https://github.com/GitJournal",
      "followers_url": "https://api.github.com/users/GitJournal/followers",
      "following_url": "https://api.github.com/users/GitJournal/following{/other_user}",
      "gists_url": "https://api.github.com/users/GitJournal/gists{/gist_id}",
      "starred_url": "https://api.github.com/users/GitJournal/starred{/owner}{/repo}",
      "subscriptions_url": "https://api.github.com/users/GitJournal/subscriptions",
      "organizations_url": "https://api.github.com/users/GitJournal/orgs",
      "repos_url": "https://api.github.com/users/GitJournal/repos",
      "events_url": "https://api.github.com/users/GitJournal/events{/privacy}",
      "received_events_url": "https://api.github.com/users/GitJournal/received_events",
      "type": "Organization",
      "site_admin": false
    },
    "html_url": "https://github.com/GitJournal/dart_git",
    "description": "A Git implementation in pure Dart",
    "fork": false,
    "url": "https://api.github.com/repos/GitJournal/dart_git",
    "forks_url": "https://api.github.com/repos/GitJournal/dart_git/forks",
    "keys_url": "https://api.github.com/repos/GitJournal/dart_git/keys{/key_id}",
    "collaborators_url": "https://api.github.com/repos/GitJournal/dart_git/collaborators{/collaborator}",
    "teams_url": "https://api.github.com/repos/GitJournal/dart_git/teams",
    "hooks_url": "https://api.github.com/repos/GitJournal/dart_git/hooks",
    "issue_events_url": "https://api.github.com/repos/GitJournal/dart_git/issues/events{/number}",
    "events_url": "https://api.github.com/repos/GitJournal/dart_git/events",
    "assignees_url": "https://api.github.com/repos/GitJournal/dart_git/assignees{/user}",
    "branches_url": "https://api.github.com/repos/GitJournal/dart_git/branches{/branch}",
    "tags_url": "https://api.github.com/repos/GitJournal/dart_git/tags",
    "blobs_url": "https://api.github.com/repos/GitJournal/dart_git/git/blobs{/sha}",
    "git_tags_url": "https://api.github.com/repos/GitJournal/dart_git/git/tags{/sha}",
    "git_refs_url": "https://api.github.com/repos/GitJournal/dart_git/git/refs{/sha}",
    "trees_url": "https://api.github.com/repos/GitJournal/dart_git/git/trees{/sha}",
    "statuses_url": "https://api.github.com/repos/GitJournal/dart_git/statuses/{sha}",
    "languages_url": "https://api.github.com/repos/GitJournal/dart_git/languages",
    "stargazers_url": "https://api.github.com/repos/GitJournal/dart_git/stargazers",
    "contributors_url": "https://api.github.com/repos/GitJournal/dart_git/contributors",
    "subscribers_url": "https://api.github.com/repos/GitJournal/dart_git/subscribers",
    "subscription_url": "https://api.github.com/repos/GitJournal/dart_git/subscription",
    "commits_url": "https://api.github.com/repos/GitJournal/dart_git/commits{/sha}",
    "git_commits_url": "https://api.github.com/repos/GitJournal/dart_git/git/commits{/sha}",
    "comments_url": "https://api.github.com/repos/GitJournal/dart_git/comments{/number}",
    "issue_comment_url": "https://api.github.com/repos/GitJournal/dart_git/issues/comments{/number}",
    "contents_url": "https://api.github.com/repos/GitJournal/dart_git/contents/{+path}",
    "compare_url": "https://api.github.com/repos/GitJournal/dart_git/compare/{base}...{head}",
    "merges_url": "https://api.github.com/repos/GitJournal/dart_git/merges",
    "archive_url": "https://api.github.com/repos/GitJournal/dart_git/{archive_format}{/ref}",
    "downloads_url": "https://api.github.com/repos/GitJournal/dart_git/downloads",
    "issues_url": "https://api.github.com/repos/GitJournal/dart_git/issues{/number}",
    "pulls_url": "https://api.github.com/repos/GitJournal/dart_git/pulls{/number}",
    "milestones_url": "https://api.github.com/repos/GitJournal/dart_git/milestones{/number}",
    "notifications_url": "https://api.github.com/repos/GitJournal/dart_git/notifications{?since,all,participating}",
    "labels_url": "https://api.github.com/repos/GitJournal/dart_git/labels{/name}",
    "releases_url": "https://api.github.com/repos/GitJournal/dart_git/releases{/id}",
    "deployments_url": "https://api.github.com/repos/GitJournal/dart_git/deployments",
    "created_at": "2019-12-24T18:08:50Z",
    "updated_at": "2020-08-02T10:59:13Z",
    "pushed_at": "2020-08-02T10:59:11Z",
    "git_url": "git://github.com/GitJournal/dart_git.git",
    "ssh_url": "git@github.com:GitJournal/dart_git.git",
    "clone_url": "https://github.com/GitJournal/dart_git.git",
    "svn_url": "https://github.com/GitJournal/dart_git",
    "homepage": null,
    "size": 134,
    "stargazers_count": 6,
    "watchers_count": 6,
    "language": "Dart",
    "has_issues": true,
    "has_projects": true,
    "has_downloads": true,
    "has_wiki": true,
    "has_pages": false,
    "forks_count": 1,
    "mirror_url": null,
    "archived": false,
    "disabled": false,
    "open_issues_count": 2,
    "license": {
      "key": "agpl-3.0",
      "name": "GNU Affero General Public License v3.0",
      "spdx_id": "AGPL-3.0",
      "url": "https://api.github.com/licenses/agpl-3.0",
      "node_id": "MDc6TGljZW5zZTE="
    },
    "forks": 1,
    "open_issues": 2,
    "watchers": 6,
    "default_branch": "master",
    "permissions": {
      "admin": true,
      "push": true,
      "pull": true
    }
  },
  {
    "id": 165047811,
    "node_id": "MDEwOlJlcG9zaXRvcnkxNjUwNDc4MTE=",
    "name": "GitJournal",
    "full_name": "GitJournal/GitJournal",
    "private": false,
    "owner": {
      "login": "GitJournal",
      "id": 46486395,
      "node_id": "MDEyOk9yZ2FuaXphdGlvbjQ2NDg2Mzk1",
      "avatar_url": "https://avatars0.githubusercontent.com/u/46486395?v=4",
      "gravatar_id": "",
      "url": "https://api.github.com/users/GitJournal",
      "html_url": "https://github.com/GitJournal",
      "followers_url": "https://api.github.com/users/GitJournal/followers",
      "following_url": "https://api.github.com/users/GitJournal/following{/other_user}",
      "gists_url": "https://api.github.com/users/GitJournal/gists{/gist_id}",
      "starred_url": "https://api.github.com/users/GitJournal/starred{/owner}{/repo}",
      "subscriptions_url": "https://api.github.com/users/GitJournal/subscriptions",
      "organizations_url": "https://api.github.com/users/GitJournal/orgs",
      "repos_url": "https://api.github.com/users/GitJournal/repos",
      "events_url": "https://api.github.com/users/GitJournal/events{/privacy}",
      "received_events_url": "https://api.github.com/users/GitJournal/received_events",
      "type": "Organization",
      "site_admin": false
    },
    "html_url": "https://github.com/GitJournal/GitJournal",
    "description": "Store your Notes in any Git Repo",
    "fork": false,
    "url": "https://api.github.com/repos/GitJournal/GitJournal",
    "forks_url": "https://api.github.com/repos/GitJournal/GitJournal/forks",
    "keys_url": "https://api.github.com/repos/GitJournal/GitJournal/keys{/key_id}",
    "collaborators_url": "https://api.github.com/repos/GitJournal/GitJournal/collaborators{/collaborator}",
    "teams_url": "https://api.github.com/repos/GitJournal/GitJournal/teams",
    "hooks_url": "https://api.github.com/repos/GitJournal/GitJournal/hooks",
    "issue_events_url": "https://api.github.com/repos/GitJournal/GitJournal/issues/events{/number}",
    "events_url": "https://api.github.com/repos/GitJournal/GitJournal/events",
    "assignees_url": "https://api.github.com/repos/GitJournal/GitJournal/assignees{/user}",
    "branches_url": "https://api.github.com/repos/GitJournal/GitJournal/branches{/branch}",
    "tags_url": "https://api.github.com/repos/GitJournal/GitJournal/tags",
    "blobs_url": "https://api.github.com/repos/GitJournal/GitJournal/git/blobs{/sha}",
    "git_tags_url": "https://api.github.com/repos/GitJournal/GitJournal/git/tags{/sha}",
    "git_refs_url": "https://api.github.com/repos/GitJournal/GitJournal/git/refs{/sha}",
    "trees_url": "https://api.github.com/repos/GitJournal/GitJournal/git/trees{/sha}",
    "statuses_url": "https://api.github.com/repos/GitJournal/GitJournal/statuses/{sha}",
    "languages_url": "https://api.github.com/repos/GitJournal/GitJournal/languages",
    "stargazers_url": "https://api.github.com/repos/GitJournal/GitJournal/stargazers",
    "contributors_url": "https://api.github.com/repos/GitJournal/GitJournal/contributors",
    "subscribers_url": "https://api.github.com/repos/GitJournal/GitJournal/subscribers",
    "subscription_url": "https://api.github.com/repos/GitJournal/GitJournal/subscription",
    "commits_url": "https://api.github.com/repos/GitJournal/GitJournal/commits{/sha}",
    "git_commits_url": "https://api.github.com/repos/GitJournal/GitJournal/git/commits{/sha}",
    "comments_url": "https://api.github.com/repos/GitJournal/GitJournal/comments{/number}",
    "issue_comment_url": "https://api.github.com/repos/GitJournal/GitJournal/issues/comments{/number}",
    "contents_url": "https://api.github.com/repos/GitJournal/GitJournal/contents/{+path}",
    "compare_url": "https://api.github.com/repos/GitJournal/GitJournal/compare/{base}...{head}",
    "merges_url": "https://api.github.com/repos/GitJournal/GitJournal/merges",
    "archive_url": "https://api.github.com/repos/GitJournal/GitJournal/{archive_format}{/ref}",
    "downloads_url": "https://api.github.com/repos/GitJournal/GitJournal/downloads",
    "issues_url": "https://api.github.com/repos/GitJournal/GitJournal/issues{/number}",
    "pulls_url": "https://api.github.com/repos/GitJournal/GitJournal/pulls{/number}",
    "milestones_url": "https://api.github.com/repos/GitJournal/GitJournal/milestones{/number}",
    "notifications_url": "https://api.github.com/repos/GitJournal/GitJournal/notifications{?since,all,participating}",
    "labels_url": "https://api.github.com/repos/GitJournal/GitJournal/labels{/name}",
    "releases_url": "https://api.github.com/repos/GitJournal/GitJournal/releases{/id}",
    "deployments_url": "https://api.github.com/repos/GitJournal/GitJournal/deployments",
    "created_at": "2019-01-10T11:27:18Z",
    "updated_at": "2020-09-04T21:15:16Z",
    "pushed_at": "2020-09-04T21:15:14Z",
    "git_url": "git://github.com/GitJournal/GitJournal.git",
    "ssh_url": "git@github.com:GitJournal/GitJournal.git",
    "clone_url": "https://github.com/GitJournal/GitJournal.git",
    "svn_url": "https://github.com/GitJournal/GitJournal",
    "homepage": "https://gitjournal.io",
    "size": 9357,
    "stargazers_count": 451,
    "watchers_count": 451,
    "language": "Dart",
    "has_issues": true,
    "has_projects": true,
    "has_downloads": true,
    "has_wiki": true,
    "has_pages": false,
    "forks_count": 47,
    "mirror_url": null,
    "archived": false,
    "disabled": false,
    "open_issues_count": 124,
    "license": {
      "key": "agpl-3.0",
      "name": "GNU Affero General Public License v3.0",
      "spdx_id": "AGPL-3.0",
      "url": "https://api.github.com/licenses/agpl-3.0",
      "node_id": "MDc6TGljZW5zZTE="
    },
    "forks": 47,
    "open_issues": 124,
    "watchers": 451,
    "default_branch": "master",
    "permissions": {
      "admin": true,
      "push": true,
      "pull": true
    }
  }
]
''';
