import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:journal/widgets/note_header.dart';

import 'note.dart';
import 'note_editor.dart';

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
  PageController pageController;

  NoteBrowsingScreenState({@required int noteIndex}) {
    pageController = new PageController(initialPage: noteIndex);
  }

  @override
  Widget build(BuildContext context) {
    var pageView = new PageView.builder(
      controller: pageController,
      itemCount: widget.notes.length,
      itemBuilder: (BuildContext context, int pos) {
        return new NoteViewer(note: widget.notes[pos]);
      },
    );

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('TIMELINE'),
      ),
      body: pageView,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.edit),
        onPressed: () {
          var route = new MaterialPageRoute(builder: (context) {
            int currentIndex = pageController.page.toInt();
            assert(currentIndex >= 0);
            assert(currentIndex < widget.notes.length);

            Note note = widget.notes[currentIndex];
            return NoteEditor.fromNote(note);
          });
          Navigator.of(context).push(route);
        },
      ),
    );
  }
}

class NoteViewer extends StatelessWidget {
  final Note note;
  final _biggerFont = const TextStyle(fontSize: 18.0);

  const NoteViewer({@required this.note});

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

    return view;
  }

  /*
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
  */
}
