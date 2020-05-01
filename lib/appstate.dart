import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/utils/logger.dart';

enum SyncStatus {
  Unknown,
  Done,
  Pulling,
  Pushing,
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
  int numChanges = 0;

  //
  // Temporary
  //
  /// This is the directory where all the git repos are stored
  String gitBaseDirectory = "";

  bool get hasJournalEntries {
    return notesFolder.hasNotes;
  }

  NotesFolderFS notesFolder;

  AppState(SharedPreferences pref) {
    localGitRepoConfigured = pref.getBool("localGitRepoConfigured") ?? false;
    remoteGitRepoConfigured = pref.getBool("remoteGitRepoConfigured") ?? false;
    localGitRepoFolderName = pref.getString("localGitRepoPath") ?? "";
    remoteGitRepoFolderName = pref.getString("remoteGitRepoPath") ?? "";
    onBoardingCompleted = pref.getBool("onBoardingCompleted") ?? false;
    gitBaseDirectory = pref.getString("gitBaseDirectory") ?? "";
  }

  void dumpToLog() {
    Log.i(" ---- Settings ---- ");
    Log.i("localGitRepoConfigured: $localGitRepoConfigured");
    Log.i("remoteGitRepoConfigured: $remoteGitRepoConfigured");
    Log.i("localGitRepoFolderName: $localGitRepoFolderName");
    Log.i("remoteGitRepoFolderName: $remoteGitRepoFolderName");
    Log.i("onBoardingCompleted: $onBoardingCompleted");
    Log.i(" ------------------ ");
  }

  Future save(SharedPreferences pref) async {
    await pref.setBool("localGitRepoConfigured", localGitRepoConfigured);
    await pref.setBool("remoteGitRepoConfigured", remoteGitRepoConfigured);
    await pref.setString("localGitRepoPath", localGitRepoFolderName);
    await pref.setString("remoteGitRepoPath", remoteGitRepoFolderName);
    await pref.setBool("onBoardingCompleted", onBoardingCompleted);
    await pref.setString("gitBaseDirectory", gitBaseDirectory);
  }
}
