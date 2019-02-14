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
    if (this.errorMessage == null || this.errorMessage.isEmpty) {
      return GitHostSetupLoadingPage("Cloning ...");
    }

    return GitHostSetupErrorPage(errorMessage);
  }
}
