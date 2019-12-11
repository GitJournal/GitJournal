import 'dart:async';
import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gitjournal/apis/git_migration.dart';
import 'package:gitjournal/appstate.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/core/git_repo.dart';
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
  final AppState appState;

  // FIXME: The gitRepo should never be changed once it has been setup
  //        We should always just be modifying the 'git remotes'
  //        With that, the StateContainer can be a StatelessWidget
  GitNoteRepository _gitRepo;

  StateContainerState(this.appState);

  @override
  void initState() {
    super.initState();

    assert(appState.localGitRepoConfigured);

    if (appState.remoteGitRepoConfigured) {
      _gitRepo = GitNoteRepository(
        baseDirectory: appState.gitBaseDirectory,
        dirName: appState.remoteGitRepoFolderName,
      );
    } else if (appState.localGitRepoConfigured) {
      _gitRepo = GitNoteRepository(
        baseDirectory: appState.gitBaseDirectory,
        dirName: appState.localGitRepoPath,
      );
    }
    appState.notesFolder = NotesFolder(null, _gitRepo.notesBasePath);

    // Just a fail safe
    if (!appState.remoteGitRepoConfigured) {
      removeExistingRemoteClone();
    }

    _loadNotes();
    syncNotes();
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
    // FIXME: We should report the notes that failed to load
    await appState.notesFolder.loadRecursively();
  }

  Future syncNotes() async {
    if (!appState.remoteGitRepoConfigured) {
      Fimber.d("Not syncing because RemoteRepo not configured");
      return true;
    }

    await _gitRepo.sync();
    await _loadNotes();

    return true;
  }

  void createFolder(NotesFolder parent, String folderName) async {
    var newFolderPath = p.join(parent.folderPath, folderName);
    var newFolder = NotesFolder(parent, newFolderPath);
    newFolder.create();

    Fimber.d("Created New Folder: " + newFolderPath);
    parent.addFolder(newFolder);

    _gitRepo.addFolder(newFolder).then((NoteRepoResult _) {
      syncNotes();
    });
  }

  void removeFolder(NotesFolder folder) {
    Fimber.d("Removing Folder: " + folder.folderPath);

    folder.parent.removeFolder(folder);
    _gitRepo.removeFolder(folder.folderPath).then((NoteRepoResult _) {
      syncNotes();
    });
  }

  void renameFolder(NotesFolder folder, String newFolderName) async {
    var oldFolderPath = folder.folderPath;
    folder.rename(newFolderName);

    _gitRepo
        .renameFolder(oldFolderPath, folder.folderPath)
        .then((NoteRepoResult _) {
      syncNotes();
    });
  }

  void addNote(Note note) {
    insertNote(0, note);
  }

  void removeNote(Note note) {
    note.parent.remove(note);
    _gitRepo.removeNote(note.filePath).then((NoteRepoResult _) async {
      // FIXME: Is there a way of figuring this amount dynamically?
      // The '4 seconds' is taken from snack_bar.dart -> _kSnackBarDisplayDuration
      // We wait an aritfical amount of time, so that the user has a change to undo
      // their delete operation, and that commit is not synced with the server, till then.
      await Future.delayed(const Duration(seconds: 4));
      syncNotes();
    });
  }

  void undoRemoveNote(Note note, int index) {
    note.parent.insert(index, note);
    _gitRepo.resetLastCommit().then((NoteRepoResult _) {
      syncNotes();
    });
  }

  void insertNote(int index, Note note) {
    Fimber.d("State Container insertNote " + index.toString());
    note.parent.insert(index, note);
    note.updateModified();
    _gitRepo.addNote(note).then((NoteRepoResult _) {
      syncNotes();
    });
  }

  void updateNote(Note note) {
    Fimber.d("State Container updateNote");
    note.updateModified();
    _gitRepo.updateNote(note).then((NoteRepoResult _) {
      syncNotes();
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

      _gitRepo = GitNoteRepository(
        baseDirectory: appState.gitBaseDirectory,
        dirName: appState.remoteGitRepoFolderName,
      );
      appState.notesFolder.folderPath = _gitRepo.notesBasePath;

      await _persistConfig();
      _loadNotes();
      syncNotes();

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
