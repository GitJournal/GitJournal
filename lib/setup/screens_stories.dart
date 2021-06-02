import 'package:flutter/material.dart';

import 'package:gitjournal/apis/githost_factory.dart';
import 'package:gitjournal/setup/autoconfigure.dart';
import 'package:gitjournal/setup/clone_url.dart';
import 'package:gitjournal/setup/error.dart';
import 'package:gitjournal/setup/key_editors.dart';
import 'package:gitjournal/setup/loading.dart';

Widget autoConfigure() {
  return Padding(
    child: GitHostSetupAutoConfigure(
      gitHostType: GitHostType.GitHub,
      onDone: (host, userInfo) => null,
    ),
    padding: const EdgeInsets.all(16.0),
  );
}

Widget cloneUrl() => GitCloneUrlPage(
      initialValue: "foo?",
      doneFunction: (val) => null,
    );

Widget keyEditors() => KeyEditor(
      GlobalKey(),
      TextEditingController(),
      (val) => null,
    );

// FIXME: Create widgets for all the errors!
Widget loadingError() => GitHostSetupErrorPage(
      "This is an error message",
    );

// FIXME: Create widgets for all the loading screen messages!
Widget loading() => GitHostSetupLoadingPage(
      "Loading Message",
    );
