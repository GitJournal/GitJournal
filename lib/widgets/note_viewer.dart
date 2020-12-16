import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gitjournal/widgets/markdown_renderer.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:provider/provider.dart';

import 'package:gitjournal/core/link.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/folder_views/common.dart';
import 'package:gitjournal/widgets/editor_scroll_view.dart';
import 'package:gitjournal/widgets/notes_backlinks.dart';

class NoteViewer extends StatelessWidget {
  final Note note;
  final NotesFolder parentFolder;
  const NoteViewer({
    Key key,
    @required this.note,
    @required this.parentFolder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          ),
          // _buildFooter(context),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );

    return view;
  }

  static md.ExtensionSet markdownExtensions() {
    // It's important to add both these inline syntaxes before the other
    // syntaxes as the LinkSyntax intefers with both of these
    var markdownExtensions = md.ExtensionSet.gitHubFlavored;
    markdownExtensions.inlineSyntaxes.insert(0, WikiLinkSyntax());
    markdownExtensions.inlineSyntaxes.insert(1, TaskListSyntax());
    return markdownExtensions;
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
  NoteTitleHeader(this.header);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Text(header, style: textTheme.headline6),
    );
  }
}
