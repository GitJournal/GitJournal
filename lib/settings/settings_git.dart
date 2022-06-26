/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/repository_manager.dart';
import 'package:gitjournal/settings/git_config.dart';
import 'package:gitjournal/settings/settings_git_remote.dart';
import 'package:gitjournal/settings/settings_git_widgets.dart';
import 'package:gitjournal/settings/widgets/settings_header.dart';
import 'package:gitjournal/settings/widgets/settings_list_option_preference.dart';

class SettingsGit extends StatelessWidget {
  static const routePath = '/settings/git';

  const SettingsGit({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var repo = Provider.of<GitJournalRepo>(context);
    var gitConfig = context.watch<GitConfig>();

    var list = ListView(
      children: [
        SettingsHeader(tr(LocaleKeys.settings_gitAuthor)),
        const GitAuthor(),
        const GitAuthorEmail(),
        ListTile(
          title: Text(tr(LocaleKeys.settings_gitRemote_title)),
          subtitle: Text(tr(LocaleKeys.settings_gitRemote_subtitle)),
          onTap: () {
            var route = MaterialPageRoute(
              builder: (context) => GitRemoteSettingsScreen(),
              settings: const RouteSettings(
                name: GitRemoteSettingsScreen.routePath,
              ),
            );
            var _ = Navigator.push(context, route);
          },
          enabled: repo.remoteGitRepoConfigured,
        ),
        ListOptionPreference<SettingsSSHKey>(
          title: tr(LocaleKeys.settings_sshKey_keyType),
          currentOption: SettingsSSHKey.fromEnum(gitConfig.sshKeyType),
          values: SettingsSSHKey.values,
          defaultValue: SettingsSSHKey.Default,
          onChange: (keyType) {
            gitConfig.sshKeyType = keyType.val;
            gitConfig.save();
          },
        ),
        RedButton(
          text: tr(LocaleKeys.settings_deleteRepo),
          onPressed: () async {
            var ok = await showDialog(
              context: context,
              builder: (_) => IrreversibleActionConfirmationDialog(
                title: LocaleKeys.settings_deleteRepo.tr(),
                subtitle:
                    LocaleKeys.settings_gitRemote_changeHost_subtitle.tr(),
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
        title: Text(LocaleKeys.settings_list_git_title.tr()),
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
