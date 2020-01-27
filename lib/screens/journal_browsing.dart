import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:page_transition/page_transition.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/state_container.dart';
import 'package:gitjournal/utils.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/widgets/journal_editor_header.dart';
import 'package:gitjournal/widgets/rename_dialog.dart';

import 'journal_editor.dart';

enum NoteBrowserDropDownChoices { Rename }

class JournalBrowsingScreen extends StatefulWidget {
  final List<Note> notes;
  final int noteIndex;

  const JournalBrowsingScreen({
    @required this.notes,
    @required this.noteIndex,
  });

  @override
  JournalBrowsingScreenState createState() {
    return JournalBrowsingScreenState(noteIndex: noteIndex);
  }
}

class JournalBrowsingScreenState extends State<JournalBrowsingScreen> {
  PageController pageController;
  int currentPage;

  JournalBrowsingScreenState({@required int noteIndex}) {
    pageController = PageController(initialPage: noteIndex);
    currentPage = noteIndex;
  }

  @override
  Widget build(BuildContext context) {
    var pageView = PageView.builder(
      controller: pageController,
      itemCount: widget.notes.length,
      itemBuilder: (BuildContext context, int pos) {
        var note = widget.notes[pos];
        return NoteViewer(
          key: ValueKey("Viewer_" + note.filePath),
          note: widget.notes[pos],
        );
      },
      onPageChanged: (int pageNum) {
        setState(() {
          currentPage = pageNum;
        });
      },
    );

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDialog(context: context, builder: _buildAlertDialog);
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              Note note = widget.notes[_currentIndex()];
              Share.share(note.body);
            },
          ),
          PopupMenuButton<NoteBrowserDropDownChoices>(
            onSelected: (NoteBrowserDropDownChoices choice) async {
              var note = widget.notes[currentPage];
              switch (choice) {
                case NoteBrowserDropDownChoices.Rename:
                  var fileName = await showDialog(
                    context: context,
                    builder: (_) => RenameDialog(
                      oldName: note.fileName,
                      inputDecoration: 'File Name',
                      dialogTitle: "Rename File",
                    ),
                  );
                  if (fileName is String) {
                    final container = StateContainer.of(context);
                    container.renameNote(note, fileName);
                  }

                  break;
              }
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<NoteBrowserDropDownChoices>>[
              const PopupMenuItem<NoteBrowserDropDownChoices>(
                value: NoteBrowserDropDownChoices.Rename,
                child: Text('Rename File'),
              ),
            ],
          ),
        ],
      ),
      body: pageView,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.edit),
        onPressed: () {
          Note note = widget.notes[_currentIndex()];
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: JournalEditor.fromNote(note),
            ),
          );
        },
      ),
    );
  }

  int _currentIndex() {
    int currentIndex = pageController.page.round();
    assert(currentIndex >= 0);
    assert(currentIndex < widget.notes.length);
    return currentIndex;
  }

  void _deleteNote(BuildContext context) {
    final stateContainer = StateContainer.of(context);
    var noteIndex = _currentIndex();
    Note note = widget.notes[noteIndex];
    stateContainer.removeNote(note);
    Navigator.pop(context);

    Fimber.d("Shwoing an undo snackbar");
    showUndoDeleteSnackbar(context, stateContainer, note, noteIndex);
  }

  Widget _buildAlertDialog(BuildContext context) {
    var title = "Are you sure you want to delete this Note?";

    return AlertDialog(
      content: Text(title),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FlatButton(
          onPressed: () {
            Navigator.pop(context); // Alert box
            _deleteNote(context);
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

class NoteViewer extends StatelessWidget {
  final Note note;
  const NoteViewer({Key key, @required this.note}) : super(key: key);

  final bool showJournalHeader = false;
  final bool showTitle = true;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    theme = theme.copyWith(
      textTheme: theme.textTheme.copyWith(
        body1: theme.textTheme.body1
            .copyWith(fontSize: Settings.instance.noteFontSize.toDouble()),
      ),
    );

    var view = SingleChildScrollView(
      child: Column(
        children: <Widget>[
          if (note.created != null && showJournalHeader)
            JournalEditorHeader(note),
          if (showTitle && note.title.isNotEmpty)
            NoteTitleHeader(note.title),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: MarkdownBody(
              data: note.body,
              styleSheet: MarkdownStyleSheet.fromTheme(theme),
              onTapLink: (String link) {
                print("Launching " + link);
                launch(link);
              },
            ),
          ),
          const SizedBox(height: 64.0),
          // _buildFooter(context),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      padding: const EdgeInsets.all(16.0),
    );

    return Hero(tag: note.filePath, child: view);
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
      child: Text(header, style: textTheme.title),
    );
  }
}
