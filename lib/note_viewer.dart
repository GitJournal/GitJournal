import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:journal/widgets/swipe_detector.dart';
import 'package:journal/widgets/note_header.dart';

import 'note_editor.dart';
import 'note.dart';

class NoteBrowsingScreen extends StatefulWidget {
  final List<Note> notes;
  final int noteIndex;

  const NoteBrowsingScreen({
    @required this.notes,
    @required this.noteIndex,
  });

  @override
  NoteBrowsingScreenState createState() {
    return new NoteBrowsingScreenState(noteIndex: noteIndex);
  }
}

class NoteBrowsingScreenState extends State<NoteBrowsingScreen> {
  int noteIndex;

  NoteBrowsingScreenState({@required this.noteIndex});

  @override
  Widget build(BuildContext context) {
    var viewer = new NoteViewer(
      note: widget.notes[noteIndex],
      showNextNoteFunc: () {
        setState(() {
          if (noteIndex < widget.notes.length - 1) noteIndex += 1;
        });
      },
      showPrevNoteFunc: () {
        setState(() {
          if (noteIndex > 0) noteIndex -= 1;
        });
      },
    );

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('TIMELINE'),
      ),
      body: viewer,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.edit),
        onPressed: () {
          var note = widget.notes[noteIndex];
          var route = new MaterialPageRoute(
              builder: (context) => new NoteEditor.fromNote(note));
          Navigator.of(context).push(route);
        },
      ),
    );
  }
}

class NoteViewer extends StatelessWidget {
  final Note note;
  final VoidCallback showNextNoteFunc;
  final VoidCallback showPrevNoteFunc;

  final _biggerFont = const TextStyle(fontSize: 18.0);

  const NoteViewer({
    @required this.note,
    @required this.showNextNoteFunc,
    @required this.showPrevNoteFunc,
  });

  @override
  Widget build(BuildContext context) {
    var view = new SingleChildScrollView(
      child: new Column(
        children: <Widget>[
          NoteHeader(note),
          Text(note.body, style: _biggerFont),
          // _buildFooter(context),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      padding: const EdgeInsets.all(16.0),
    );

    return new SwipeDetector(
      child: view,
      onLeftSwipe: showNextNoteFunc,
      onRightSwipe: showPrevNoteFunc,
    );
  }

  Widget _buildFooter(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: new Row(
        children: <Widget>[
          new IconButton(
            icon: new Icon(Icons.arrow_left),
            tooltip: 'Previous Entry',
            onPressed: showPrevNoteFunc,
          ),
          new Expanded(
            flex: 10,
            child: new Text(''),
          ),
          new IconButton(
            icon: new Icon(Icons.arrow_right),
            tooltip: 'Next Entry',
            onPressed: showNextNoteFunc,
          ),
        ],
      ),
    );
  }
}
