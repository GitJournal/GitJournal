/*
 * SPDX-FileCopyrightText: 2019-2025 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:dart_git/config.dart';
import 'package:dart_git/git.dart';
import 'package:flutter/material.dart';
import 'package:git_setup/clone_url.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/utils/utils.dart';
import 'package:provider/provider.dart';

class GitRemoteHost extends StatefulWidget {
  const GitRemoteHost({super.key});

  @override
  State<GitRemoteHost> createState() => _GitRemoteHostState();
}

class _GitRemoteHostState extends State<GitRemoteHost> {
  var remoteHost = "";

  @override
  Widget build(BuildContext context) {
    var repo = context.watch<GitJournalRepo>();

    if (remoteHost.isEmpty) {
      repo.remoteConfigs().then((list) {
        setState(() {
          if (!mounted) return;
          remoteHost = list.first.url;
        });
      });

      return const SizedBox();
    }

    return ListTile(
      title: Text(context.loc.settingsGitRemoteHost),
      subtitle: Text(remoteHost),
      onTap: () async {
        var newUrl = await showDialog(
          context: context,
          builder: (context) => _GitRemoteHostDialog(remoteHost),
        );

        if (newUrl != null && newUrl != remoteHost) {
          await _updateRemoteHost(newUrl);
        }
      },
    );
  }

  Future<void> _updateRemoteHost(String newUrl) async {
    var repo = context.read<GitJournalRepo>();
    var gitRepo = GitRepository.load(repo.repoPath);
    var remoteConfigs = gitRepo.config.remotes;
    if (remoteConfigs.isEmpty) {
      showErrorSnackbar(context, context.loc.settingsNoRemoteConfigured);
      return;
    }

    if (remoteConfigs.length > 1) {
      showErrorSnackbar(
          context, context.loc.settingsMultipleGitRemotesNotSupported);
      return;
    }

    var remoteConfig = remoteConfigs.first;
    gitRepo.config.remotes[0] = GitRemoteConfig(
      name: remoteConfig.name,
      url: newUrl,
      fetch: remoteConfig.fetch,
    );
    gitRepo.saveConfig();

    setState(() {
      remoteHost = newUrl;
    });
  }
}

class _GitRemoteHostDialog extends StatefulWidget {
  final String remoteUrl;
  const _GitRemoteHostDialog(this.remoteUrl);

  @override
  __GitRemoteHostDialogState createState() => __GitRemoteHostDialogState();
}

class __GitRemoteHostDialogState extends State<_GitRemoteHostDialog> {
  final GitRemoteHostKey = GlobalKey<FormFieldState<String>>();

  @override
  Widget build(BuildContext context) {
    var isValid = GitRemoteHostKey.currentState?.isValid;
    var remoteUrl = GitRemoteHostKey.currentState?.value;

    var form = TextFormField(
      key: GitRemoteHostKey,
      keyboardType: TextInputType.url,
      validator: (String? url) => isCloneUrlValid(context, url),
      textInputAction: TextInputAction.done,
      initialValue: widget.remoteUrl,
      autovalidateMode: AutovalidateMode.always,
      onChanged: (_) {
        setState(() {
          // To trigger the isValid check
        });
      },
    );

    return AlertDialog(
      title: Text(context.loc.settingsGitRemoteHost),
      content: form,
      actions: <Widget>[
        TextButton(
          child: Text(context.loc.settingsCancel),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          onPressed: isValid == true
              ? () => Navigator.of(context).pop(remoteUrl)
              : null,
          child: Text(context.loc.settingsOk),
        ),
      ],
    );
  }
}
