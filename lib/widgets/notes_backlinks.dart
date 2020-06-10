import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'package:gitjournal/folder_views/common.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';

class NoteBacklinkRenderer extends StatefulWidget {
  final Note note;
  final NotesFolderFS rootFolder;

  NoteBacklinkRenderer({
    @required this.note,
    @required this.rootFolder,
  });

  @override
  _NoteBacklinkRendererState createState() => _NoteBacklinkRendererState();
}

class _NoteBacklinkRendererState extends State<NoteBacklinkRenderer> {
  List<Note> linkedNotes = [];

  @override
  void initState() {
    super.initState();

    _initStateAsync();
  }

  Future<void> _initStateAsync() async {
    var predicate = (Note n) async {
      var links = await n.fetchLinks();
      var matchedLink = links.firstWhere(
        (l) {
          if (l.filePath != null) {
            return l.filePath == widget.note.filePath;
          }

          var term = widget.note.pathSpec();
          term = p.basenameWithoutExtension(term);
          return term == l.term;
        },
        orElse: () => null,
      );
      return matchedLink != null;
    };

    var l = await widget.rootFolder.matchNotes(predicate);
    if (!mounted) return;
    setState(() {
      linkedNotes = l;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (linkedNotes.isEmpty) {
      return Container();
    }

    var title = widget.note.title;
    if (title.isEmpty) {
      title = widget.note.fileName;
    }

    var num = linkedNotes.length;
    var textTheme = Theme.of(context).textTheme;
    var c = Column(
      children: <Widget>[
        Text(
          plural("widgets.backlinks.title", num),
          style: textTheme.headline6,
        ),
        const SizedBox(height: 8.0),
        for (var note in linkedNotes)
          NoteSnippet(
            note: note,
            parentNote: widget.note,
            onTap: () {
              openNoteEditor(context, note);
            },
          ),
      ],
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
    );

    var backgroundColor = Colors.grey[200];
    if (Theme.of(context).brightness == Brightness.dark) {
      backgroundColor = Theme.of(context).backgroundColor;
    }
    return Container(
      color: backgroundColor,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
        child: c,
      ),
    );
  }
}

class NoteSnippet extends StatelessWidget {
  final Note note;
  final Note parentNote;
  final Function onTap;

  NoteSnippet({
    @required this.note,
    @required this.parentNote,
    @required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    var title = note.title;
    if (title.isEmpty) {
      title = note.fileName;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
      child: GestureDetector(
        onTap: () {
          openNoteEditor(context, note);
        },
        child: Container(
          color: theme.scaffoldBackgroundColor,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              Text('$title', style: textTheme.bodyText1),
              const SizedBox(height: 8.0),
              _buildSummary(context),
            ],
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var links = note.links();
    if (links == null || links.isEmpty) {
      return Container();
    }

    var link = links.where((l) {
      if (l.filePath != null) {
        return l.filePath == note.filePath;
      }

      var term = parentNote.pathSpec();
      term = p.basenameWithoutExtension(term);
      return term == l.term;
    }).first;

    var body = note.body.split('\n');
    var paragraph = body.firstWhere(
      (line) => line.contains('[${link.term}]'),
      orElse: () => "",
    );
    // vHanda: This isn't a very fool proof way of figuring out the line

    return Text(
      paragraph,
      style: textTheme.bodyText2,
      maxLines: 3,
    );
  }
}
