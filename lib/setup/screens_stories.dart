import 'package:flutter/material.dart';

import 'package:gitjournal/apis/githost_factory.dart';
import 'package:gitjournal/setup/autoconfigure.dart';
import 'package:gitjournal/setup/clone_url.dart';
import 'package:gitjournal/setup/error.dart';
import 'package:gitjournal/setup/loading.dart';
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
      onDone: (host, userInfo) => null,
    ),
  );
}

Widget cloneUrl() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: GitCloneUrlPage(
      initialValue: "foo?",
      doneFunction: (val) => null,
    ),
  );
}

// FIXME: Create widgets for all the errors!
Widget loadingError() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: GitHostSetupErrorPage(
      "This is an error message",
    ),
  );
}

// FIXME: Create widgets for all the loading screen messages!
Widget loading() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
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
