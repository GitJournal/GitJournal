import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
        (l) => l.filePath == widget.note.filePath,
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

    var textTheme = Theme.of(context).textTheme;
    var c = Column(
      children: <Widget>[
        Text('BackLinks', style: textTheme.headline5),
        const SizedBox(height: 8.0),
        for (var n in linkedNotes)
          NoteSnippet(n, () {
            openNoteEditor(context, n);
          }),
      ],
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 16.0),
      child: c,
    );
  }
}

class NoteSnippet extends StatelessWidget {
  final Note note;
  final Function onTap;

  NoteSnippet(this.note, this.onTap);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var title = note.title;
    if (title.isEmpty) {
      title = note.fileName;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0, 8.0),
      child: GestureDetector(
        onTap: () {
          openNoteEditor(context, note);
        },
        child: Text('-   $title', style: textTheme.bodyText1),
      ),
    );
  }
}
