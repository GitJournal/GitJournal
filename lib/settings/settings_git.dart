/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/repository_manager.dart';
import 'package:gitjournal/settings/git_config.dart';
import 'package:gitjournal/settings/settings_git_remote.dart';
import 'package:gitjournal/settings/settings_git_widgets.dart';
import 'package:gitjournal/settings/widgets/settings_header.dart';
import 'package:gitjournal/settings/widgets/settings_list_preference.dart';
import 'package:provider/provider.dart';

class SettingsGit extends StatelessWidget {
  static const routePath = '/settings/git';

  const SettingsGit({super.key});

  @override
  Widget build(BuildContext context) {
    var repo = Provider.of<GitJournalRepo>(context);
    var gitConfig = context.watch<GitConfig>();

    var list = ListView(
      children: [
        SettingsHeader(context.loc.settingsGitAuthor),
        const GitAuthor(),
        const GitAuthorEmail(),
        ListTile(
          title: Text(context.loc.settingsGitRemoteTitle),
          subtitle: Text(context.loc.settingsGitRemoteSubtitle),
          onTap: () {
            var route = MaterialPageRoute(
              builder: (context) => GitRemoteSettingsScreen(),
              settings: const RouteSettings(
                name: GitRemoteSettingsScreen.routePath,
              ),
            );
            Navigator.push(context, route);
          },
          enabled: repo.remoteGitRepoConfigured,
        ),
        ListPreference(
          title: context.loc.settingsSshKeyKeyType,
          currentOption: SettingsSSHKey.fromEnum(gitConfig.sshKeyType)
              .toPublicString(context),
          options: SettingsSSHKey.options
              .map((f) => f.toPublicString(context))
              .toList(),
          onChange: (String publicStr) {
            var val = SettingsSSHKey.fromPublicString(context, publicStr);
            gitConfig.sshKeyType = val.toEnum();
            gitConfig.save();
          },
        ),
        RedButton(
          text: context.loc.settingsDeleteRepo,
          onPressed: () async {
            var ok = await showDialog(
              context: context,
              builder: (_) => IrreversibleActionConfirmationDialog(
                title: context.loc.settingsDeleteRepo,
                subtitle: context.loc.settingsGitRemoteChangeHostSubtitle,
              ),
            );
            if (ok == null) {
              return;
            }

            var repoManager = context.read<RepositoryManager>();
            await repoManager.deleteCurrent();

            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.settingsListGitTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: list,
    );
  }
}
