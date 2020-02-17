import 'package:flutter/material.dart';

import 'error.dart';
import 'loading.dart';

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
