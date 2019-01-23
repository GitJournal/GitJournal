import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:journal/appstate.dart';
import 'package:journal/note.dart';
import 'package:journal/storage/notes_repository.dart';
import 'package:journal/storage/git_storage.dart';
import 'package:journal/datetime_utils.dart';

import 'package:journal/apis/git_migration.dart';

class StateContainer extends StatefulWidget {
  final Widget child;
  final bool localGitRepoConfigured;
  final bool remoteGitRepoConfigured;
  final String localGitRepoPath;
  final String remoteGitRepoPath;
  final String gitBaseDirectory;

  StateContainer({
    @required this.localGitRepoConfigured,
    @required this.remoteGitRepoConfigured,
    @required this.localGitRepoPath,
    @required this.remoteGitRepoPath,
    @required this.gitBaseDirectory,
    @required this.child,
  });

  static StateContainerState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedStateContainer)
            as _InheritedStateContainer)
        .data;
  }

  @override
  State<StatefulWidget> createState() {
    var st = StateContainerState();
    st.appState.localGitRepoConfigured = localGitRepoConfigured;
    st.appState.remoteGitRepoConfigured = remoteGitRepoConfigured;
    st.appState.localGitRepoPath = localGitRepoPath;
    st.appState.remoteGitRepoPath = remoteGitRepoPath;
    st.appState.gitBaseDirectory = gitBaseDirectory;

    return st;
  }
}

class StateContainerState extends State<StateContainer> {
  AppState appState = AppState();
  NoteRepository noteRepo;

  @override
  void initState() {
    super.initState();

    assert(appState.localGitRepoConfigured);

    if (appState.remoteGitRepoConfigured) {
      noteRepo = new GitNoteRepository(
        baseDirectory: appState.gitBaseDirectory,
        dirName: appState.remoteGitRepoPath,
      );
    } else if (appState.localGitRepoConfigured) {
      noteRepo = new GitNoteRepository(
        baseDirectory: appState.gitBaseDirectory,
        dirName: appState.localGitRepoPath,
      );
    }

    // Just a fail safe
    if (!appState.remoteGitRepoConfigured) {
      removeExistingRemoteClone();
    }

    _loadNotesFromDisk();
    _syncNotes();
  }

  void removeExistingRemoteClone() async {
    var remoteGitDir = new Directory(
        p.join(appState.gitBaseDirectory, appState.remoteGitRepoPath));
    var dotGitDir = new Directory(p.join(remoteGitDir.path, ".git"));

    bool exists = await dotGitDir.exists();
    if (exists) {
      await remoteGitDir.delete(recursive: true);
    }
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

  Future syncNotes() async {
    if (!appState.remoteGitRepoConfigured) {
      print("Not syncing because RemoteRepo not configured");
      return true;
    }

    await noteRepo.sync();

    try {
      appState.isLoadingFromDisk = true;
      var loadedNotes = await noteRepo.listNotes();
      setState(() {
        appState.isLoadingFromDisk = false;
        appState.notes = loadedNotes;
      });
    } catch (err, stack) {
      setState(() {
        print("Load Notes From Disk Error: " + err.toString());
        print(stack.toString());
        appState.isLoadingFromDisk = false;
      });
    }

    return true;
  }

  void _syncNotes() {
    if (!appState.remoteGitRepoConfigured) {
      print("Not syncing because RemoteRepo not configured");
      return;
    }

    print("Starting to syncNotes");
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
    print("State Container insertNote");
    setState(() {
      if (note.fileName == null || note.fileName.isEmpty) {
        note.fileName = toIso8601WithTimezone(note.created) + '.md';
      }
      appState.notes.insert(index, note);
      noteRepo.addNote(note).then((NoteRepoResult _) {
        _syncNotes();
      });
    });
  }

  void updateNote(Note note) {
    print("State Container updateNote");
    setState(() {
      noteRepo.updateNote(note).then((NoteRepoResult _) {
        _syncNotes();
      });
    });
  }

  void completeOnBoarding() {
    setState(() async {
      this.appState.remoteGitRepoConfigured = true;
      this.appState.remoteGitRepoPath = "journal";

      await migrateGitRepo(
        fromGitBasePath: appState.localGitRepoPath,
        toGitBasePath: appState.remoteGitRepoPath,
        gitBasePath: appState.gitBaseDirectory,
      );

      noteRepo = new GitNoteRepository(
        baseDirectory: appState.gitBaseDirectory,
        dirName: appState.remoteGitRepoPath,
      );

      await _persistConfig();
      _loadNotesFromDisk();
      _syncNotes();
    });
  }

  Future _persistConfig() async {
    var pref = await SharedPreferences.getInstance();
    await pref.setBool(
        "remoteGitRepoConfigured", appState.remoteGitRepoConfigured);
    await pref.setString("remoteGitRepoPath", appState.remoteGitRepoPath);
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
