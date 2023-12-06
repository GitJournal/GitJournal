/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gitjournal/core/folder/flattened_filtered_notes_folder.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/markdown/md_yaml_note_serializer.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/views/inline_tags_view.dart';
import 'package:gitjournal/folder_views/folder_view.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/widgets/app_bar_menu_button.dart';
import 'package:gitjournal/widgets/app_drawer.dart';
import 'package:gitjournal/widgets/future_builder_with_progress.dart';
import 'package:gitjournal/widgets/pro_overlay.dart';
import 'package:provider/provider.dart';

class TagListingScreen extends StatelessWidget {
  static const routePath = '/tags';

  const TagListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var rootFolder = context.watch<NotesFolderFS>();
    var inlineTagsView = InlineTagsProvider.of(context);

    return FutureBuilderWithProgress(future: () async {
      var allTags = await rootFolder.getNoteTagsRecursively(inlineTagsView);
      return _buildWithTags(context, SplayTreeSet.from(allTags));
    }());
  }

  Widget _buildWithTags(BuildContext context, Iterable<String> allTags) {
    Widget body;
    if (allTags.isNotEmpty) {
      body = ListView(
        children: <Widget>[
          for (var tag in allTags) _buildTagTile(context, tag),
        ],
      );
    } else {
      body = Center(
        child: Text(
          context.loc.screensTagsEmpty,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.w300,
            color: Colors.grey[350],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.screensTagsTitle),
        leading: GJAppBarMenuButton(),
      ),
      body: Scrollbar(
        child: ProOverlay(child: body),
      ),
      drawer: AppDrawer(),
    );
  }

  Widget _buildTagTile(BuildContext context, String tag) {
    var theme = Theme.of(context);
    var titleColor = theme.textTheme.displayLarge!.color;

    return ListTile(
      leading: FaIcon(FontAwesomeIcons.tag, color: titleColor),
      title: Text(tag),
      onTap: () {
        var route = MaterialPageRoute(
          builder: (context) => FutureBuilderWithProgress(
            future: _tagFolderView(context, tag),
          ),
          settings: const RouteSettings(name: TagListingScreen.routePath),
        );
        Navigator.push(context, route);
      },
    );
  }
}

Future<FolderView> _tagFolderView(BuildContext context, String tag) async {
  var rootFolder = context.read<NotesFolderFS>();
  var inlineTagsView = InlineTagsProvider.of(context);

  var folder = await FlattenedFilteredNotesFolder.load(
    rootFolder,
    filter: (Note n) async {
      if (n.tags.contains(tag)) {
        return true;
      }

      var inlineTags = await inlineTagsView.fetch(n);
      if (inlineTags.contains(tag)) {
        return true;
      }

      return false;
    },
    title: tag,
  );

  final propNames = NoteSerializationSettings();
  return FolderView(
    notesFolder: folder,
    newNoteExtraProps: {
      propNames.tagsKey: [tag],
    },
  );
}
