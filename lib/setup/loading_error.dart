import 'package:flutter/material.dart';

import 'error.dart';
import 'loading.dart';

class GitHostSetupLoadingErrorPage extends StatelessWidget {
  final String errorMessage;
  final String loadingMessage;

  GitHostSetupLoadingErrorPage({
    @required this.errorMessage,
    @required this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (errorMessage == null || errorMessage.isEmpty) {
      return GitHostSetupLoadingPage(loadingMessage);
    }

    return GitHostSetupErrorPage(errorMessage);
  }
}
