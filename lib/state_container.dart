import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import 'package:journal/note.dart';
import 'package:journal/storage/serializers.dart';
import 'package:journal/storage/notes_repository.dart';
import 'package:journal/storage/git_storage.dart';
import 'package:journal/storage/git.dart';

Future<Directory> getNotesDir() async {
  var appDir = await getGitBaseDirectory();
  var dir = new Directory(p.join(appDir.path, "journal"));
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
  AppState appState = AppState();

  NoteRepository noteRepo = new GitNoteRepository(
    getDirectory: getNotesDir,
    dirName: "journal",
    gitCloneUrl: "root@bcn.vhanda.in:git/test",
  );

  @override
  void initState() {
    super.initState();

    _loadNotesFromDisk();
    _syncNotes();
  }

  void _loadNotesFromDisk() {
    print("Loading Notes From Disk");
    appState.isLoadingFromDisk = true;
    noteRepo.listNotes().then((loadedNotes) {
      setState(() {
        appState.isLoadingFromDisk = false;
        appState.notes = loadedNotes;
      });
    }).catchError((err, stack) {
      setState(() {
        print("Load Notes From Disk Error: " + err.toString());
        print(stack.toString());
        appState.isLoadingFromDisk = false;
      });
    });
  }

  void _syncNotes() {
    print("Starting to syncNOtes");
    this.noteRepo.sync().then((loaded) {
      print("NotesRepo Synced: " + loaded.toString());
      _loadNotesFromDisk();
    }).catchError((err) {
      print("NotesRepo Sync: " + err.toString());
    });
  }

  void addNote(Note note) {
    insertNote(0, note);
  }

  void removeNote(Note note) {
    setState(() {
      appState.notes.remove(note);
      noteRepo.removeNote(note).then((NoteRepoResult _) {
        _syncNotes();
      });
    });
  }

  void insertNote(int index, Note note) {
    setState(() {
      print("insertNote: " + note.toString());
      if (note.id == null || note.id.isEmpty) {
        note.id = new Uuid().v4();
      }
      appState.notes.insert(index, note);
      noteRepo.addNote(note).then((NoteRepoResult _) {
        _syncNotes();
      });
    });
  }

  void updateNote(Note note) {
    setState(() {
      noteRepo.updateNote(note).then((NoteRepoResult _) {
        _syncNotes();
      });
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
