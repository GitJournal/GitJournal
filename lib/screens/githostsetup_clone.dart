import 'package:flutter/material.dart';

import 'githostsetup_error.dart';
import 'githostsetup_loading.dart';

class GitHostSetupGitClone extends StatelessWidget {
  final String errorMessage;

  GitHostSetupGitClone({
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (errorMessage == null || errorMessage.isEmpty) {
      return GitHostSetupLoadingPage("Cloning ...");
    }

    return GitHostSetupErrorPage(errorMessage);
  }
}
