import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:journal/file_storage.dart';
import 'package:journal/note.dart';
import 'package:journal/screens/home_screen.dart';

class JournalApp extends StatefulWidget {
  final FileStorage fileStorage;

  JournalApp({@required this.fileStorage});

  @override
  JournalAppState createState() {
    return new JournalAppState();
  }
}

class JournalAppState extends State<JournalApp> {
  AppState appState = AppState.loading();

  @override
  void initState() {
    super.initState();

    widget.fileStorage.loadNotes().then((loadedNotes) {
      setState(() {
        appState = AppState(notes: loadedNotes);
      });
    }).catchError((err) {
      setState(() {
        print("Got Error");
        print(err);
        appState.isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Journal',
      home: new HomeScreen(
        appState: appState,
        noteAdder: addNote,
      ),
      theme: new ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.lightBlue[800],
        accentColor: Colors.cyan[600],
      ),
    );
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);

    widget.fileStorage.saveNotes(appState.notes);
  }

  void addNote(Note note) {
    print("Adding a note " + note.toString());
    setState(() {
      note.id = new Uuid().v4();
      appState.notes.insert(0, note);
    });
  }

  void removeNote(Note note) {
    setState(() {
      appState.notes.remove(note);
    });
  }

  // FIXME: Implement this!
  void updateNote(Note note) {
    setState(() {
      //appState.notes.
      //appState.notes.remove(note);
    });
  }
}
