import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'note.dart';

class NoteViewer extends StatelessWidget {
  final Note note;
  final _biggerFont = const TextStyle(fontSize: 18.0);

  const NoteViewer({this.note});

  @override
  Widget build(BuildContext context) {
    // FIXME: Add some kind of a header?

    var formatter = new DateFormat('dd MMM, yyyy');
    var title = formatter.format(note.createdAt);

    var bodyWidget = new SingleChildScrollView(
      child: new Text(note.body, style: _biggerFont),
      padding: const EdgeInsets.all(8.0),
    );

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(title),
      ),
      body: bodyWidget,
    );
  }
}
