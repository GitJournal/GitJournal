import 'package:flutter/material.dart';
import 'package:function_types/function_types.dart';

import 'package:git_bindings/git_bindings.dart';

import 'package:gitjournal/analytics.dart';
import 'package:gitjournal/apis/githost_factory.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/utils/logger.dart';

import 'error.dart';
import 'loading.dart';

class GitHostSetupAutoConfigureComplete extends StatefulWidget {
  final GitHost gitHost;
  final GitHostRepo repo;
  final Func1<String, void> onDone;

  GitHostSetupAutoConfigureComplete({
    @required this.gitHost,
    @required this.repo,
    @required this.onDone,
  });

  @override
  GitHostSetupAutoConfigureCompleteState createState() {
    return GitHostSetupAutoConfigureCompleteState();
  }
}

class GitHostSetupAutoConfigureCompleteState
    extends State<GitHostSetupAutoConfigureComplete> {
  String errorMessage = "";

  String _message = "...";

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  void _initAsync() async {
    Log.d("Starting autoconfigure copletion");

    try {
      Log.i("Generating SSH Key");
      setState(() {
        _message = "Generating SSH Key";
      });
      var publicKey = await generateSSHKeys(comment: "GitJournal");

      Log.i("Adding as a deploy key");
      if (mounted) {
        setState(() {
          _message = "Adding as a Deploy Key";
        });
      }
      await widget.gitHost.addDeployKey(publicKey, widget.repo.fullName);
    } on Exception catch (e, stacktrace) {
      _handleGitHostException(e, stacktrace);
      return;
    }
    widget.onDone(widget.repo.cloneUrl);
  }

  void _handleGitHostException(Exception e, StackTrace stacktrace) {
    Log.d("GitHostSetupAutoConfigureComplete: " + e.toString());
    setState(() {
      errorMessage = e.toString();
      getAnalytics().logEvent(
        name: "githostsetup_error",
        parameters: <String, String>{
          'errorMessage': errorMessage,
        },
      );

      logException(e, stacktrace);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (errorMessage == null || errorMessage.isEmpty) {
      return GitHostSetupLoadingPage(_message);
    }

    return GitHostSetupErrorPage(errorMessage);
  }
}
