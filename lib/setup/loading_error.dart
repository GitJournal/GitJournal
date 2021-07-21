import 'package:flutter/material.dart';

import 'clone.dart';
import 'error.dart';
import 'loading.dart';

class GitHostSetupLoadingErrorPage extends StatelessWidget {
  final String? errorMessage;
  final String loadingMessage;

  GitHostSetupLoadingErrorPage({
    required this.errorMessage,
    required this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (errorMessage == null || errorMessage!.isEmpty) {
      return GitHostSetupLoadingPage(loadingMessage);
    }

    return GitHostSetupErrorPage(errorMessage!);
  }
}

class GitHostCloningPage extends StatelessWidget {
  final String? errorMessage;
  final String loadingMessage;
  final GitTransferProgress cloneProgress;

  GitHostCloningPage({
    required this.errorMessage,
    required this.loadingMessage,
    required this.cloneProgress,
  });

  @override
  Widget build(BuildContext context) {
    if (errorMessage == null || errorMessage!.isEmpty) {
      return GitHostSetupLoadingPage(loadingMessage);
    }

    return GitHostSetupErrorPage(errorMessage!);
  }
}
