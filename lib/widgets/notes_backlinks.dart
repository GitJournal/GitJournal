/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gitjournal/core/folder/notes_folder.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/link.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/views/note_links_view.dart';
import 'package:gitjournal/folder_views/common.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/utils/link_resolver.dart';
import 'package:gitjournal/widgets/future_builder_with_progress.dart';
import 'package:gitjournal/widgets/pro_overlay.dart';

class NoteBacklinkRenderer extends StatefulWidget {
  final Note note;
  final NotesFolderFS rootFolder;
  final NotesFolder parentFolder;
  final NoteLinksView linksView;

  const NoteBacklinkRenderer({
    required this.note,
    required this.rootFolder,
    required this.parentFolder,
    required this.linksView,
  });

  @override
  _NoteBacklinkRendererState createState() => _NoteBacklinkRendererState();
}

class _NoteBacklinkRendererState extends State<NoteBacklinkRenderer> {
  List<Note> _linkedNotes = [];

  @override
  void initState() {
    super.initState();

    _initStateAsync();
  }

  Future<void> _initStateAsync() async {
    Future<bool> predicate(Note n) async {
      // Log.d("NoteBacklinkRenderer Predicate", props: {"filePath": n.filePath});

      var links = await widget.linksView.fetchLinks(n);
      var linkResolver = LinkResolver(n);
      var matchedLink = links.firstWhereOrNull(
        (l) {
          var matchedNote = linkResolver.resolveLink(l);
          if (matchedNote == null) {
            return false;
          }

          return matchedNote.filePath == widget.note.filePath;
        },
      );

      // Log.d("NoteBacklinkRenderer Predicate ${matchedLink != null}");
      return matchedLink != null;
    }

    var l = await widget.rootFolder.matchNotes(predicate);
    if (!mounted) return;
    setState(() {
      _linkedNotes = l;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_linkedNotes.isEmpty) {
      return Container();
    }

    var num = _linkedNotes.length;
    var textTheme = Theme.of(context).textTheme;
    var c = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          context.loc.widgetsBacklinksTitle(num),
          style: textTheme.titleLarge,
        ),
        const SizedBox(height: 8.0),
        for (var note in _linkedNotes)
          NoteSnippet(
            note: note,
            parentNote: widget.note,
            onTap: () {
              openNoteEditor(context, note, widget.parentFolder);
            },
          ),
      ],
    );

    var backgroundColor = Colors.grey[200];
    if (Theme.of(context).brightness == Brightness.dark) {
      backgroundColor = Theme.of(context).colorScheme.surface;
    }
    var child = Container(
      color: backgroundColor,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
        child: c,
      ),
    );
    return ProOverlay(child: child);
  }
}

class NoteSnippet extends StatelessWidget {
  final Note note;
  final Note parentNote;
  final void Function() onTap;

  const NoteSnippet({
    required this.note,
    required this.parentNote,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    var title = note.title ?? note.fileName;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: theme.scaffoldBackgroundColor,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: textTheme.bodyLarge),
              const SizedBox(height: 8.0),
              _buildSummary(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    var linksProvider = NoteLinksProvider.of(context);
    return FutureBuilderWithProgress(future: () async {
      var links = await linksProvider.fetchLinks(note);
      if (links.isEmpty) {
        return Container();
      }
      return _buildSummaryWithLinks(context, links);
    }());
  }

  Widget _buildSummaryWithLinks(BuildContext context, List<Link> links) {
    links = links.where((l) {
      var linkResolver = LinkResolver(note);
      var resolvedNote = linkResolver.resolveLink(l);
      if (resolvedNote == null) {
        return false;
      }
      return resolvedNote.filePath == parentNote.filePath;
    }).toList();
    if (links.isEmpty) {
      return Container();
    }
    var link = links.first;

    var body = note.body.split('\n');
    var paragraph = body.firstWhere(
      (String line) {
        return link.isWikiLink
            ? line.contains('[[${link.wikiTerm}}]]')
            : line.contains('[${link.publicTerm}]');
      },
      orElse: () => "",
    );

    var textTheme = Theme.of(context).textTheme;

    // vHanda: This isn't a very fool proof way of figuring out the line
    // FIXME: Ideally, we should be parsing the entire markdown properly and rendering all of it
    return RichText(
      text: TextSpan(
        children: _extraMetaLinks(textTheme.bodyMedium!, paragraph),
      ),
      maxLines: 3,
    );
  }
}

List<TextSpan> _extraMetaLinks(TextStyle textStyle, String line) {
  var regExp = WikiLinkSyntax().pattern;

  var spans = <TextSpan>[];

  while (true) {
    var match = regExp.firstMatch(line);
    if (match == null) {
      break;
    }
    var text = line.substring(0, match.start);
    spans.add(TextSpan(style: textStyle, text: text));

    text = match.group(0)!;
    spans.add(TextSpan(
        style: textStyle.copyWith(fontWeight: FontWeight.bold), text: text));

    if (match.end < line.length) {
      line = line.substring(match.end);
    } else {
      line = "";
      break;
    }
  }

  if (line.isNotEmpty) {
    spans.add(TextSpan(style: textStyle, text: line));
  }

  return spans;
}
