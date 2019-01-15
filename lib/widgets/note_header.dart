import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:journal/note.dart';

class NoteHeader extends StatelessWidget {
  final Note note;

  NoteHeader(this.note);

  @override
  Widget build(BuildContext context) {
    var dateStr = DateFormat('MMM, yyyy').format(note.created);
    var timeStr = DateFormat('EEEE H:m').format(note.created);

    var bigNum = new Text(
      note.created.day.toString(),
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
}
