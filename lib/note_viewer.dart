import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:journal/state_container.dart';
import 'package:journal/widgets/note_header.dart';

import 'note.dart';
import 'note_editor.dart';
import 'utils.dart';

class NoteBrowsingScreen extends StatefulWidget {
  final List<Note> notes;
  final int noteIndex;

  const NoteBrowsingScreen({
    @required this.notes,
    @required this.noteIndex,
  });

  @override
  NoteBrowsingScreenState createState() {
    return NoteBrowsingScreenState(noteIndex: noteIndex);
  }
}

class NoteBrowsingScreenState extends State<NoteBrowsingScreen> {
  PageController pageController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  NoteBrowsingScreenState({@required int noteIndex}) {
    pageController = PageController(initialPage: noteIndex);
  }

  @override
  Widget build(BuildContext context) {
    var pageView = PageView.builder(
      controller: pageController,
      itemCount: widget.notes.length,
      itemBuilder: (BuildContext context, int pos) {
        return NoteViewer(note: widget.notes[pos]);
      },
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('TIMELINE'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              final stateContainer = StateContainer.of(context);
              var noteIndex = _currentIndex();
              Note note = widget.notes[noteIndex];
              stateContainer.removeNote(note);
              Navigator.pop(context);

              print("Shwoing an undo snackbar");
              var snackbar = buildUndoDeleteSnackbar(context, note, noteIndex);
              _scaffoldKey.currentState
                ..removeCurrentSnackBar()
                ..showSnackBar(snackbar);
            },
          ),
        ],
      ),
      body: pageView,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.edit),
        onPressed: () {
          var route = MaterialPageRoute(builder: (context) {
            Note note = widget.notes[_currentIndex()];
            return NoteEditor.fromNote(note);
          });
          Navigator.of(context).push(route);
        },
      ),
    );
  }

  int _currentIndex() {
    int currentIndex = pageController.page.toInt();
    assert(currentIndex >= 0);
    assert(currentIndex < widget.notes.length);
    return currentIndex;
  }
}

class NoteViewer extends StatelessWidget {
  final Note note;
  final _biggerFont = const TextStyle(fontSize: 18.0);

  const NoteViewer({@required this.note});

  @override
  Widget build(BuildContext context) {
    var view = SingleChildScrollView(
      child: Column(
        children: <Widget>[
          NoteHeader(note),
          Text(note.body, style: _biggerFont),
          SizedBox(height: 64.0),
          // _buildFooter(context),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      padding: const EdgeInsets.all(16.0),
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
