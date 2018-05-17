import 'package:flutter/material.dart';

class NoteEditor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var bodyWidget = new Container(
      child: new TextField(
        autofocus: true,
        keyboardType: TextInputType.multiline,
        maxLines: 5000,
        decoration: new InputDecoration(
          hintText: 'Write here',
        ),
      ),
      padding: const EdgeInsets.all(8.0),
    );

    var newJournalScreen = new Scaffold(
      appBar: new AppBar(
        title: new Text("May 15, 17:35"),
      ),
      body: bodyWidget,
    );

    return newJournalScreen;
  }
}
