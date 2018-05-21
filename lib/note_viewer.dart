import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'note.dart';

class NoteViewer extends StatelessWidget {
  final Note note;
  final _biggerFont = const TextStyle(fontSize: 18.0);

  const NoteViewer({this.note});

  @override
  Widget build(BuildContext context) {
    var bodyWidget = new SingleChildScrollView(
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

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('TIMELINE'),
      ),
      body: bodyWidget,
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
            onPressed: () {},
          ),
          new Expanded(
            flex: 10,
            child: new Text(''),
          ),
          new IconButton(
            icon: new Icon(Icons.arrow_right),
            tooltip: 'Next Entry',
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
