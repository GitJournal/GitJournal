import 'package:shared_preferences/shared_preferences.dart';
import 'package:fimber/fimber.dart';

import 'package:gitjournal/core/notes_folder.dart';

enum SyncStatus {
  Unknown,
  Done,
  Loading,
  Error,
}

class AppState {
  //
  // Saved on Disk
  //
  // FIXME: These should be figured out by querying the 'git remotes'
  String localGitRepoFolderName = "";
  bool localGitRepoConfigured = false;

  String remoteGitRepoFolderName = "";
  bool remoteGitRepoConfigured = false;

  bool onBoardingCompleted = false;

  SyncStatus syncStatus = SyncStatus.Unknown;

  //
  // Temporary
  //
  /// This is the directory where all the git repos are stored
  String gitBaseDirectory = "";

  bool get hasJournalEntries {
    return notesFolder.hasNotes;
  }

  NotesFolder notesFolder;

  AppState(SharedPreferences pref) {
    localGitRepoConfigured = pref.getBool("localGitRepoConfigured") ?? false;
    remoteGitRepoConfigured = pref.getBool("remoteGitRepoConfigured") ?? false;
    localGitRepoFolderName = pref.getString("localGitRepoPath") ?? "";
    remoteGitRepoFolderName = pref.getString("remoteGitRepoPath") ?? "";
    onBoardingCompleted = pref.getBool("onBoardingCompleted") ?? false;
  }

  void dumpToLog() {
    Fimber.d(" ---- Settings ---- ");
    Fimber.d("localGitRepoConfigured: $localGitRepoConfigured");
    Fimber.d("remoteGitRepoConfigured: $remoteGitRepoConfigured");
    Fimber.d("localGitRepoFolderName: $localGitRepoFolderName");
    Fimber.d("remoteGitRepoFolderName: $remoteGitRepoFolderName");
    Fimber.d("onBoardingCompleted: $onBoardingCompleted");
    Fimber.d(" ------------------ ");
  }

  Future save(SharedPreferences pref) async {
    await pref.setBool("localGitRepoConfigured", localGitRepoConfigured);
    await pref.setBool("remoteGitRepoConfigured", remoteGitRepoConfigured);
    await pref.setString("localGitRepoPath", localGitRepoFolderName);
    await pref.setString("remoteGitRepoPath", remoteGitRepoFolderName);
    await pref.setBool("onBoardingCompleted", onBoardingCompleted);
  }
}
