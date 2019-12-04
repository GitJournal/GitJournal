import 'dart:async';
import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gitjournal/analytics.dart';
import 'package:gitjournal/apis/git_migration.dart';
import 'package:gitjournal/appstate.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/core/note_fileName.dart';
import 'package:gitjournal/storage/git_storage.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

class StateContainer extends StatefulWidget {
  final Widget child;
  final AppState appState;
  StateContainer({
    @required this.appState,
    @required this.child,
  });

  static StateContainerState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedStateContainer)
            as _InheritedStateContainer)
        .data;
  }

  @override
  State<StatefulWidget> createState() {
    return StateContainerState(appState);
  }
}

class StateContainerState extends State<StateContainer> {
  AppState appState;
  GitNoteRepository noteRepo;

  StateContainerState(this.appState);

  @override
  void initState() {
    super.initState();

    assert(appState.localGitRepoConfigured);

    if (appState.remoteGitRepoConfigured) {
      noteRepo = GitNoteRepository(
        baseDirectory: appState.gitBaseDirectory,
        dirName: appState.remoteGitRepoFolderName,
      );
    } else if (appState.localGitRepoConfigured) {
      noteRepo = GitNoteRepository(
        baseDirectory: appState.gitBaseDirectory,
        dirName: appState.localGitRepoPath,
      );
    }
    appState.notesFolder = NotesFolder(null, noteRepo.notesBasePath);

    // Just a fail safe
    if (!appState.remoteGitRepoConfigured) {
      removeExistingRemoteClone();
    }

    _loadNotesFromDisk();
    _syncNotes();
  }

  void removeExistingRemoteClone() async {
    var remoteGitDir = Directory(
        p.join(appState.gitBaseDirectory, appState.remoteGitRepoFolderName));
    var dotGitDir = Directory(p.join(remoteGitDir.path, ".git"));

    bool exists = await dotGitDir.exists();
    if (exists) {
      await remoteGitDir.delete(recursive: true);
    }
  }

  Future<void> _loadNotes() async {
    await appState.notesFolder.loadRecursively();
  }

  void _loadNotesFromDisk() {
    Fimber.d("Loading Notes From Disk");
    _loadNotes().then((void _) {
      setState(() {
        getAnalytics().logEvent(
          name: "notes_loaded",
        );
      });
    }).catchError((err, stack) {
      setState(() {
        Fimber.d("Load Notes From Disk Error: " + err.toString());
        Fimber.d(stack.toString());

        getAnalytics().logEvent(
          name: "notes_loading_failed",
          parameters: <String, dynamic>{
            'error': err.toString(),
          },
        );
      });
    });
  }

  Future syncNotes() async {
    if (!appState.remoteGitRepoConfigured) {
      Fimber.d("Not syncing because RemoteRepo not configured");
      return true;
    }

    await noteRepo.sync();

    try {
      await _loadNotes();
      setState(() {
        // TODO: Inform exactly what notes have changed?
      });
    } catch (err, stack) {
      setState(() {
        Fimber.d("Load Notes From Disk Error: " + err.toString());
        Fimber.d(stack.toString());
      });
    }

    return true;
  }

  void _syncNotes() {
    if (!appState.remoteGitRepoConfigured) {
      Fimber.d("Not syncing because RemoteRepo not configured");
      return;
    }

    Fimber.d("Starting to syncNotes");
    noteRepo.sync().then((loaded) {
      Fimber.d("NotesRepo Synced: " + loaded.toString());
      _loadNotesFromDisk();
    }).catchError((err) {
      Fimber.d("NotesRepo Sync: " + err.toString());
    });
  }

  void addNote(Note note) {
    insertNote(0, note);
  }

  void removeNote(Note note) {
    setState(() {
      note.parent.remove(note);
      noteRepo.removeNote(note.filePath).then((NoteRepoResult _) async {
        // FIXME: Is there a way of figuring this amount dynamically?
        // The '4 seconds' is taken from snack_bar.dart -> _kSnackBarDisplayDuration
        // We wait an aritfical amount of time, so that the user has a change to undo
        // their delete operation, and that commit is not synced with the server, till then.
        await Future.delayed(const Duration(seconds: 4));
        _syncNotes();
      });
    });
  }

  void undoRemoveNote(Note note, int index) {
    setState(() {
      note.parent.insert(index, note);
      noteRepo.resetLastCommit().then((NoteRepoResult _) {
        _syncNotes();
      });
    });
  }

  void insertNote(int index, Note note) {
    Fimber.d("State Container insertNote " + index.toString());
    setState(() {
      if (note.filePath == null || note.filePath.isEmpty) {
        var parentPath = note.parent != null
            ? note.parent.folderPath
            : noteRepo.notesBasePath;
        note.filePath = p.join(parentPath, getFileName(note));
      }
      note.parent.insert(index, note);
      noteRepo.addNote(note).then((NoteRepoResult _) {
        _syncNotes();
      });
    });
  }

  void updateNote(Note note) {
    Fimber.d("State Container updateNote");
    setState(() {
      // Update the git repo
      noteRepo.updateNote(note).then((NoteRepoResult _) {
        _syncNotes();
      });
    });
  }

  void completeGitHostSetup() {
    () async {
      appState.remoteGitRepoConfigured = true;
      appState.remoteGitRepoFolderName = "journal";

      await migrateGitRepo(
        fromGitBasePath: appState.localGitRepoPath,
        toGitBaseFolder: appState.remoteGitRepoFolderName,
        gitBasePath: appState.gitBaseDirectory,
      );

      noteRepo = GitNoteRepository(
        baseDirectory: appState.gitBaseDirectory,
        dirName: appState.remoteGitRepoFolderName,
      );
      appState.notesFolder = NotesFolder(null, noteRepo.notesBasePath);

      await _persistConfig();
      _loadNotesFromDisk();
      _syncNotes();

      setState(() {});
    }();
  }

  void completeOnBoarding() {
    setState(() {
      appState.onBoardingCompleted = true;
      _persistConfig();
    });
  }

  Future _persistConfig() async {
    var pref = await SharedPreferences.getInstance();
    await appState.save(pref);
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
