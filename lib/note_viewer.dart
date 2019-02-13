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
    return NoteBrowsingScreenState(noteIndex: noteIndex);
  }
}

class NoteBrowsingScreenState extends State<NoteBrowsingScreen> {
  PageController pageController;

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
      appBar: AppBar(
        title: Text('TIMELINE'),
      ),
      body: pageView,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.edit),
        onPressed: () {
          var route = MaterialPageRoute(builder: (context) {
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
    var view = SingleChildScrollView(
      child: Column(
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
