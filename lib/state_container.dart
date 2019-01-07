import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import 'package:journal/note.dart';
import 'package:journal/storage/serializers.dart';
import 'package:journal/storage/notes_repository.dart';
import 'package:journal/storage/file_storage.dart';
import 'package:journal/storage/git.dart';

Future<Directory> getNotesDir() async {
  var appDir = await getGitBaseDirectory();
  var dir = new Directory(p.join(appDir.path, "notes"));
  await dir.create();

  return dir;
}

class StateContainer extends StatefulWidget {
  final Widget child;

  StateContainer({
    @required this.child,
  });

  static StateContainerState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedStateContainer)
            as _InheritedStateContainer)
        .data;
  }

  @override
  State<StatefulWidget> createState() {
    return StateContainerState();
  }
}

class StateContainerState extends State<StateContainer> {
  AppState appState = AppState.loading();
  NoteRepository noteRepo = new FileStorage(
    getDirectory: getNotesDir,
    noteSerializer: new MarkdownYAMLSerializer(),
    fileNameGenerator: (Note note) => note.id,
  );

  @override
  void initState() {
    super.initState();

    noteRepo.listNotes().then((loadedNotes) {
      setState(() {
        appState = AppState(notes: loadedNotes);
      });
    }).catchError((err) {
      setState(() {
        print("Load Notes Error:");
        print(err);
        appState.isLoading = false;
      });
    });
  }

  void addNote(Note note) {
    setState(() {
      note.id = new Uuid().v4();
      appState.notes.insert(0, note);
      noteRepo.addNote(note);
    });
  }

  void removeNote(Note note) {
    setState(() {
      appState.notes.remove(note);
      noteRepo.removeNote(note);
    });
  }

  void insertNote(int index, Note note) {
    setState(() {
      appState.notes.insert(index, note);
      noteRepo.addNote(note);
    });
  }

  // FIXME: Implement this!
  void updateNote(Note note) {
    setState(() {
      noteRepo.updateNote(note);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedStateContainer(
      data: this,
      child: widget.child,
    );
  }
}

class _InheritedStateContainer extends InheritedWidget {
  final StateContainerState data;

  _InheritedStateContainer({
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(key: key, child: child);

  // Note: we could get fancy here and compare whether the old AppState is
  // different than the current AppState. However, since we know this is the
  // root Widget, when we make changes we also know we want to rebuild Widgets
  // that depend on the StateContainer.
  @override
  bool updateShouldNotify(_InheritedStateContainer old) => true;
}
