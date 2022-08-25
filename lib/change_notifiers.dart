/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitjournal/core/folder/notes_folder_config.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/views/inline_tags_view.dart';
import 'package:gitjournal/core/views/note_links_view.dart';
import 'package:gitjournal/core/views/summary_view.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/repository_manager.dart';
import 'package:gitjournal/settings/app_config.dart';
import 'package:gitjournal/settings/git_config.dart';
import 'package:gitjournal/settings/markdown_renderer_config.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/settings/storage_config.dart';

class GitJournalChangeNotifiers extends StatelessWidget {
  final RepositoryManager repoManager;
  final AppConfig appConfig;
  final SharedPreferences pref;
  final Widget child;

  const GitJournalChangeNotifiers({
    required this.repoManager,
    required this.appConfig,
    required this.pref,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var app = ChangeNotifierProvider.value(
      value: repoManager,
      child: Consumer<RepositoryManager>(
        builder: (_, repoManager, __) => _buildMarkdownSettings(
            child: buildForRepo(repoManager.currentRepo)),
      ),
    );

    return ChangeNotifierProvider.value(
      value: appConfig,
      child: app,
    );
  }

  Widget buildForRepo(GitJournalRepo? repo) {
    if (repo == null) {
      return child;
    }

    return ChangeNotifierProvider.value(
      value: repoManager.currentRepo!,
      child: Consumer<GitJournalRepo>(
        builder: (_, repo, __) => _buildRepoDependentProviders(repo),
      ),
    );
  }

  Widget _buildRepoDependentProviders(GitJournalRepo repo) {
    var folderConfig = repo.folderConfig;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GitConfig>.value(value: repo.gitConfig),
        ChangeNotifierProvider<StorageConfig>.value(value: repo.storageConfig),
        ChangeNotifierProvider<Settings>.value(value: repo.settings),
        ChangeNotifierProvider<NotesFolderConfig>.value(value: folderConfig),
      ],
      child: _buildNoteMaterializedViews(
        repo,
        ChangeNotifierProvider<NotesFolderFS>.value(
          value: repo.rootFolder,
          child: child,
        ),
      ),
    );
  }

  Widget _buildNoteMaterializedViews(GitJournalRepo repo, Widget child) {
    var repoId = repo.id;
    return Nested(
      children: [
        NoteSummaryProvider(repoId: repoId),
        InlineTagsProvider(repoId: repoId),
        NoteLinksProvider(repoId: repoId),
      ],
      child: child,
    );
  }

  Widget _buildMarkdownSettings({required Widget child}) {
    return Consumer<RepositoryManager>(
      builder: (_, repoManager, __) {
        var markdown = MarkdownRendererConfig(repoManager.currentId, pref);
        markdown.load();

        return ChangeNotifierProvider.value(value: markdown, child: child);
      },
    );
  }
}
