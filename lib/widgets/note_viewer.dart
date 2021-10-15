/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:org_flutter/org_flutter.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/core/folder/notes_folder.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/org_links_handler.dart';
import 'package:gitjournal/core/views/note_links_view.dart';
import 'package:gitjournal/editors/editor_scroll_view.dart';
import 'package:gitjournal/folder_views/common.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/widgets/markdown_renderer.dart';
import 'package:gitjournal/widgets/notes_backlinks.dart';

class NoteViewer extends StatelessWidget {
  final Note note;
  final NotesFolder parentFolder;
  const NoteViewer({
    Key? key,
    required this.note,
    required this.parentFolder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (note.fileFormat == NoteFileFormat.OrgMode) {
      var handler = OrgLinkHandler(context, note);

      return Org(
        note.body,
        onLinkTap: handler.launchUrl,
        onLocalSectionLinkTap: (OrgSection section) {
          Log.d("local section link: " + section.toString());
        },
        onSectionLongPress: (OrgSection section) {
          Log.d('local section long-press: ' + section.headline.rawTitle!);
        },
      );
    }

    final rootFolder = Provider.of<NotesFolderFS>(context);
    var view = EditorScrollView(
      child: Column(
        children: <Widget>[
          NoteTitleHeader(note.title),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: MarkdownRenderer(
              note: note,
              onNoteTapped: (note) =>
                  openNoteEditor(context, note, parentFolder),
            ),
          ),
          const SizedBox(height: 16.0),
          NoteBacklinkRenderer(
            note: note,
            rootFolder: rootFolder,
            parentFolder: parentFolder,
            linksView: NoteLinksProvider.of(context),
          ),
          // _buildFooter(context),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );

    return view;
  }

  /*
  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_left),
            tooltip: 'Previous Entry',
            onPressed: showPrevNoteFunc,
          ),
          Expanded(
            flex: 10,
            child: Text(''),
          ),
          IconButton(
            icon: Icon(Icons.arrow_right),
            tooltip: 'Next Entry',
            onPressed: showNextNoteFunc,
          ),
        ],
      ),
    );
  }
  */
}

class NoteTitleHeader extends StatelessWidget {
  final String header;
  const NoteTitleHeader(this.header);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Text(header, style: textTheme.headline6),
    );
  }
}
