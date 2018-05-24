import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:journal/widgets/swipe_detector.dart';

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
          _buildHeader(context),
          new Text(note.body, style: _biggerFont),
          _buildFooter(context),
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

  Widget _buildHeader(BuildContext context) {
    var dateStr = DateFormat('MMM dd, yyyy').format(note.createdAt);
    var timeStr = DateFormat('EEEE H:m').format(note.createdAt);

    var bigNum = new Text(
      note.createdAt.day.toString(),
      style: TextStyle(fontSize: 40.0),
    );

    var dateText = new Text(
      dateStr,
      style: TextStyle(fontSize: 18.0),
    );

    var timeText = new Text(
      timeStr,
      style: TextStyle(fontSize: 18.0),
    );

    var w = new Row(
      children: <Widget>[
        bigNum,
        new Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: new Column(
            children: <Widget>[
              dateText,
              timeText,
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
      ],
    );

    return new Padding(
      padding: new EdgeInsets.only(top: 6.0, bottom: 6.0 * 3),
      child: w,
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
