import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'clone.dart';
import 'error.dart';
import 'loading.dart';

class GitHostCloningPage extends StatelessWidget {
  final String? errorMessage;
  final String loadingMessage;
  final GitTransferProgress cloneProgress;

  GitHostCloningPage({
    required this.errorMessage,
    required this.cloneProgress,
  }) : loadingMessage = tr('setup.cloning');

  @override
  Widget build(BuildContext context) {
    if (errorMessage == null || errorMessage!.isEmpty) {
      return GitHostSetupLoadingPage(loadingMessage);
    }

    return GitHostSetupErrorPage(errorMessage!);
  }
}
