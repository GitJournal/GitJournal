import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:journal/note.dart';

class NoteHeader extends StatelessWidget {
  final Note note;

  NoteHeader(this.note);

  @override
  Widget build(BuildContext context) {
    var dateStr = DateFormat('MMMM, yyyy').format(note.created);
    var timeStr = DateFormat('EEEE HH:mm').format(note.created);

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
        SizedBox(width: 8.0),
        Column(
          children: <Widget>[
            dateText,
            timeText,
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );

    return new Padding(
      padding: new EdgeInsets.only(top: 8.0, bottom: 18.0),
      child: w,
    );
  }
}
